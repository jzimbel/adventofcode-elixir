defmodule AdventOfCode.Algo.AStar do
  @moduledoc """
  Generalized A* graph search.
  """
  require AdventOfCode.PriorityQueue, as: Q

  use TypedStruct

  @typedoc """
  Graph being searched.

  This is usually a Grid.
  """
  @type graph :: term

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
    field :current, AdventOfCode.Algo.AStar.node_id(), enforce: true
    field :heuristic, integer | :infinity, enforce: true
    field :score, integer, default: 0

    field :came_from, %{AdventOfCode.Algo.AStar.node_id() => AdventOfCode.Algo.AStar.node_id()},
      default: %{}
  end

  #######################
  # Global search state #
  #######################
  typedstruct module: Search, enforce: true do
    field :impl, module
    field :graph, AdventOfCode.Algo.AStar.graph()
    field :goal, term
    field :q, Q.t(State.t())
    field :shortest_path_cost, integer | :infinity
    # maps visited nodes to their min scores
    field :visited, %{AdventOfCode.Algo.AStar.node_id() => integer}
    field :exhaustive?, boolean
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
    @callback next_states(State.t(), Search.t()) :: Enumerable.t(State.t())
    @callback at_goal?(State.t(), goal :: term) :: boolean
    @callback heuristic(AdventOfCode.Algo.AStar.node_id(), goal :: term) :: non_neg_integer
    @callback priority(State.t()) :: term

    defmacro __using__(_) do
      quote do
        @behaviour AdventOfCode.Algo.AStar.Impl

        @impl true
        def next_states(state, search) do
          prev = state.came_from[state.current]

          for {neighbor, ?.} when neighbor != prev <-
                AdventOfCode.Grid.adjacent_cells(search.graph, state.current, :cardinal) do
            %AdventOfCode.Algo.AStar.State{
              current: neighbor,
              heuristic: heuristic(neighbor, search.goal),
              score: state.score + 1,
              came_from: Map.put(state.came_from, neighbor, state.current)
            }
          end
        end

        @impl true
        def at_goal?(state, goal), do: state.current == goal

        @impl true
        def heuristic(coords, goal),
          do: AdventOfCode.Algo.Helpers.manhattan_distance(coords, goal)

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

  @type opt :: {:impl, module} | {:exhaustive?, boolean}

  @spec run(
          AdventOfCode.Grid.t(),
          AdventOfCode.Grid.coordinates(),
          AdventOfCode.Grid.coordinates()
        ) ::
          Enumerable.t(path_info)
  @spec run(graph(), node_id(), term, [opt]) :: Enumerable.t(path_info)
  def run(graph, start_node_id, goal, opts \\ []) do
    impl = Keyword.get(opts, :impl, DefaultImpl)
    exhaustive? = Keyword.get(opts, :exhaustive?, true)

    Code.ensure_loaded!(impl)

    start = %State{
      current: start_node_id,
      heuristic: impl.heuristic(start_node_id, goal)
    }

    %Search{
      impl: impl,
      graph: graph,
      goal: goal,
      q: Q.new([start], &impl.priority/1),
      shortest_path_cost: :infinity,
      visited: %{},
      exhaustive?: exhaustive?
    }
    |> Stream.unfold(&a_star/1)
  end

  # Recurses until it finds a path or runs out of nodes to search.
  # Emits the path if it is a shortest path, otherwise returns nil to end the stream.
  # (We know there are no more shortest paths as soon as we see a longer one.)
  @spec a_star(Search.t()) :: {{path, integer}, Search.t()} | nil
  defp a_star(search) when Q.is_empty(search.q), do: nil

  defp a_star(search) do
    {state, search} = get_and_update_in(search.q, &Q.pop!/1)

    case check_state_score(state, search) do
      :ok ->
        search = update_in(search.visited, &Map.put(&1, state.current, state.score))

        if search.impl.at_goal?(state, search.goal) and
             state.score <= search.shortest_path_cost do
          path = reconstruct_path(state.current, state.came_from)
          cost = state.score
          {{path, cost}, put_in(search.shortest_path_cost, cost)}
        else
          a_star(push_next_states(search, state))
        end

      :skip ->
        a_star(search)

      :halt ->
        nil
    end
  end

  defp check_state_score(state, search)
       when state.score > search.shortest_path_cost,
       do: :halt

  defp check_state_score(state, search) do
    case Map.fetch(search.visited, state.current) do
      {:ok, prev_score} when state.score > prev_score -> :skip
      {:ok, prev_score} when not search.exhaustive? and state.score == prev_score -> :skip
      _ -> :ok
    end
  end

  defp push_next_states(search, state) do
    for next_state <- search.impl.next_states(state, search), reduce: search do
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
