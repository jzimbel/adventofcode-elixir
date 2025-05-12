defmodule AdventOfCode.Algo.AStar do
  @moduledoc false

  alias AdventOfCode.Grid, as: G
  import AdventOfCode.Algo.Helpers

  @typep t :: %__MODULE__{
           grid: G.t(),
           start: G.coordinates(),
           goal: G.coordinates(),
           heuristic: (G.coordinates(), G.coordinates() -> integer),
           open_set: MapSet.t(G.coordinates()),
           came_from: %{G.coordinates() => G.coordinates()},
           g_score: %{G.coordinates() => integer},
           f_score: %{G.coordinates() => integer}
         }

  @enforce_keys [:grid, :start, :goal, :heuristic, :open_set, :came_from, :g_score, :f_score]
  defstruct @enforce_keys

  @spec run(G.t(), G.coordinates(), G.coordinates()) :: {:ok, list(G.coordinates())} | :error
  @spec run(G.t(), G.coordinates(), G.coordinates(), heuristic) ::
          {:ok, list(G.coordinates())} | :error
        when heuristic: (G.coordinates(), G.coordinates() -> integer)
  def run(grid, start, goal, heuristic \\ &manhattan_distance/2) do
    %__MODULE__{
      grid: grid,
      start: start,
      goal: goal,
      heuristic: heuristic,
      open_set: MapSet.new([start]),
      came_from: %{},
      # default val :infinity
      g_score: %{start => 0},
      # default val :infinity
      f_score: %{start => heuristic.(start, goal)}
    }
    |> a_star()
  end

  @spec a_star(t()) :: {:ok, list(G.coordinates())} | :error
  defp a_star(%__MODULE__{} = state) do
    if Enum.empty?(state.open_set) do
      :error
    else
      current =
        Enum.min_by(state.open_set, fn coords ->
          Map.get(state.f_score, coords, :infinity)
        end)

      case update_state(state, current) do
        {:halt, path} -> {:ok, path}
        {:cont, state} -> a_star(state)
      end
    end
  end

  defp update_state(%__MODULE__{goal: current} = state, current) do
    {:halt, reconstruct_path(current, state.came_from)}
  end

  defp update_state(state, current) do
    state = update_in(state.open_set, &MapSet.delete(&1, current))

    state =
      for {neighbor, ?.} <- G.adjacent_cells(state.grid, current, :cardinal), reduce: state do
        state -> update_neighbor(state, neighbor, current)
      end

    {:cont, state}
  end

  defp update_neighbor(state, neighbor, current) do
    tentative_g_score = Map.fetch!(state.g_score, current) + 1

    if tentative_g_score < Map.get(state.g_score, neighbor, :infinity) do
      %{
        state
        | open_set: MapSet.put(state.open_set, neighbor),
          came_from: Map.put(state.came_from, neighbor, current),
          g_score: Map.put(state.g_score, neighbor, tentative_g_score),
          f_score:
            Map.put(
              state.f_score,
              neighbor,
              tentative_g_score + state.heuristic.(neighbor, state.goal)
            )
      }
    else
      state
    end
  end

  defp reconstruct_path(coords, came_from, path \\ []) do
    case Map.fetch(came_from, coords) do
      {:ok, prev} -> reconstruct_path(prev, came_from, [coords | path])
      :error -> [coords | path]
    end
  end
end
