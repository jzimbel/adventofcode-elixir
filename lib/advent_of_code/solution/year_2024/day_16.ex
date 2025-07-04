defmodule AdventOfCode.Solution.Year2024.Day16 do
  alias AdventOfCode.Grid, as: G
  alias AdventOfCode.Algo

  use AdventOfCode.Solution.SharedParse

  defmodule DeerRaceImpl do
    use AdventOfCode.Algo.AStar.Impl
    import Algo.Helpers

    @impl true
    def next_states(state, search) do
      {coords, _} = state.current
      {prev_coords, _} = Map.get(state.came_from, state.current, {nil, nil})

      for {neighbor, ?.} <- G.adjacent_cells(search.graph, coords, :cardinal),
          neighbor != prev_coords do
        next = {neighbor, subtract(neighbor, coords)}

        %Algo.AStar.State{
          current: next,
          heuristic: heuristic(next, search.goal),
          score: state.score + cost(state.current, next),
          came_from: Map.put(state.came_from, next, state.current)
        }
      end
    end

    @impl true
    def at_goal?(state, goal_coords) do
      {coords, _heading} = state.current
      coords == goal_coords
    end

    @impl true
    def heuristic({coords, _heading} = current, goal) do
      min_turns(current, goal) * 1000 + manhattan_distance(coords, goal)
    end

    defp cost({_, heading}, {_, heading}), do: 1
    defp cost({_, {0, _}}, {_, {_, 0}}), do: 1001
    defp cost({_, {_, 0}}, {_, {0, _}}), do: 1001

    # at goal
    defp min_turns({goal, _heading}, goal), do: 0

    # directly above or below goal
    defp min_turns({{gx, y}, {_hx, hy}}, {gx, gy}) do
      abs(sign(gy - y) - hy)
    end

    # directly left or right of goal
    defp min_turns({{x, gy}, {hx, _hy}}, {gx, gy}) do
      abs(sign(gx - x) - hx)
    end

    # not aligned with goal on either axis - facing left/right
    defp min_turns({{x, _y}, {hx, 0}}, {gx, _gy}) do
      max(1, abs(sign(gx - x) - hx))
    end

    # not aligned with goal on either axis - facing up/down
    defp min_turns({{_x, y}, {0, hy}}, {_gx, gy}) do
      max(1, abs(sign(gy - y) - hy))
    end

    defp subtract({x1, y1}, {x2, y2}), do: {x1 - x2, y1 - y2}

    defp sign(0), do: 0
    defp sign(n) when n > 0, do: 1
    defp sign(n) when n < 0, do: -1
  end

  @impl true
  def parse(input) do
    grid = G.from_input(input)

    {start_coords, ?S} = Enum.find(grid, &match?({_, ?S}, &1))
    {goal_coords, ?E} = Enum.find(grid, &match?({_, ?E}, &1))

    grid = G.replace(grid, %{start_coords => ?., goal_coords => ?.})
    start_position = {start_coords, {1, 0}}

    {grid, start_position, goal_coords}
  end

  def part1({grid, start, goal}) do
    {:ok, {_path, cost}} = Algo.a_star_one(grid, start, goal, DeerRaceImpl)
    cost
  end

  def part2({grid, start, goal}) do
    grid
    |> Algo.a_star_all(start, goal, DeerRaceImpl)
    |> Stream.flat_map(fn {path, _cost} -> Enum.map(path, fn {coords, _heading} -> coords end) end)
    |> Stream.uniq()
    |> Enum.count()
  end
end
