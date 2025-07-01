defmodule AdventOfCode.Algo.AStar do
  @moduledoc """
  A* search implementation for Grid.
  """
  alias AdventOfCode.Grid, as: G
  require AdventOfCode.PriorityQueue, as: Q
  use TypedStruct

  @typedoc """
  Unique identifier for a node in the graph being searched.

  Usually this is a coordinate pair (`{x,y}`) or coordinates + heading (`{{x,y}, {hx,hy}}`)
  when searching a Grid.
  """
  @type node_id :: term

  ##############
  # Node state #
  ##############
  typedstruct module: State do
    field(:current, AdventOfCode.Algo.AStar.node_id(), enforce: true)
    field(:heuristic, integer | :infinity, enforce: true)
    field(:score, integer, default: 0)

    field(:came_from, %{AdventOfCode.Algo.AStar.node_id() => AdventOfCode.Algo.AStar.node_id()},
      default: %{}
    )
  end

  #######################
  # Global search state #
  #######################
  typedstruct module: Search, enforce: true do
    field(:impl, module)
    field(:grid, G.t())
    field(:goal, G.coordinates())
    field(:q, MapSet.t(State.t()))
    field(:shortest_path_cost, integer | :infinity)
    # maps visited nodes to their min scores
    field(:visited, %{AdventOfCode.Algo.AStar.node_id() => integer})
  end

  #############
  # Behaviour #
  #############
  defmodule Impl do
    # TODO: Convert to protocol?
    # Complicating factor: both the implementation
    # and the generalized code need to access state values.
    # So, likely would need to add more callbacks for the generalized code
    # to use, so that it isn't directly reaching into the struct fields.
    @callback next(State.t(), Search.t()) :: Enumerable.t(State.t())
    @callback at_goal?(State.t(), G.coordinates()) :: boolean
    @callback priority(State.t()) :: term

    defmacro __using__(_) do
      quote do
        @behaviour AdventOfCode.Algo.AStar.Impl

        @impl true
        def next(state, search) do
          for {neighbor, ?.} <-
                AdventOfCode.Grid.adjacent_cells(search.grid, state.current, :cardinal) do
            %AdventOfCode.Algo.AStar.State{
              current: neighbor,
              heuristic: AdventOfCode.Algo.Helpers.manhattan_distance(neighbor, search.goal),
              score: state.score + 1,
              came_from: Map.put(state.came_from, neighbor, state.current)
            }
          end
        end

        @impl true
        def at_goal?(state, goal), do: state.current == goal

        @impl true
        def priority(state) do
          state.score + state.heuristic
        end

        defoverridable AdventOfCode.Algo.AStar.Impl
      end
    end
  end

  defmodule DefaultImpl, do: use(Impl)

  ###############
  # MAIN MODULE #
  ###############

  @type path_info :: {path, cost :: integer}
  @type path :: list(node_id())

  @spec run(G.t(), State.t(), G.coordinates()) :: Enumerable.t(path_info)
  @spec run(G.t(), State.t(), term, module) :: Enumerable.t(path_info)
  def run(grid, start, goal, impl \\ DefaultImpl) do
    Code.ensure_loaded!(impl)

    search =
      %Search{
        impl: impl,
        grid: grid,
        goal: goal,
        q: Q.new([start], &impl.priority/1),
        shortest_path_cost: :infinity,
        visited: %{}
      }

    Stream.unfold(search, &a_star/1)
  end

  # Recurses until it finds a path or runs out of nodes to search.
  # Emits the path if it is a shortest path, otherwise returns nil to end the stream.
  # (We know there are no more shortest paths as soon as we see a longer one)
  @spec a_star(Search.t()) :: {{path, integer}, Search.t()} | nil
  defp a_star(search) when Q.is_empty(search.q), do: nil

  defp a_star(search) do
    {state, search} = get_and_update_in(search.q, &Q.pop!/1)

    case check_state_score(state, search.visited, search.shortest_path_cost) do
      :ok ->
        search = update_in(search.visited, &Map.put(&1, state.current, state.score))

        if search.impl.at_goal?(state, search.goal) and
             state.score <= search.shortest_path_cost do
          path = reconstruct_path(state.current, state.came_from)
          cost = state.score
          search = %{search | shortest_path_cost: cost}
          {{path, cost}, search}
        else
          a_star(update_search(search, state))
        end

      :skip ->
        a_star(search)

      :halt ->
        nil
    end
  end

  defp check_state_score(state, _visited, shortest_path_cost)
       when state.score > shortest_path_cost,
       do: :halt

  defp check_state_score(state, visited, _shortest_path_cost) do
    case Map.fetch(visited, state.current) do
      {:ok, prev_score} when state.score > prev_score -> :skip
      _ -> :ok
    end
  end

  defp update_search(search, state) do
    for next_state <- search.impl.next(state, search), reduce: search do
      search -> update_in(search.q, &Q.push(&1, next_state))
    end
  end

  defp reconstruct_path(node_id, came_from, path \\ []) do
    path = [node_id | path]

    case Map.fetch(came_from, node_id) do
      {:ok, prev_node_id} -> reconstruct_path(prev_node_id, came_from, path)
      :error -> path
    end
  end
end
