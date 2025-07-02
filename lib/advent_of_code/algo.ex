defmodule AdventOfCode.Algo do
  @moduledoc """
  Pathfinding and other algorithm implementations.
  """
  alias AdventOfCode.Algo.AStar
  alias AdventOfCode.Grid, as: G

  @doc """
  A* search.

  Returns a stream that emits `{path, cost}` pairs for all shortest paths in the graph.

  You may pass an `AdventOfCode.Algo.AStar.Impl` callback module to customize search behaviour.

  Default behaviour:
  - Searches a Grid with char values.
  - Cells with ?. values are considered reachable. All others are unreachable.
  - A cell's neighbors are its cardinally adjacent ?.-valued cells.
  - Distance to a neighbor is always 1.
  - Heuristic is Manhattan distance.
  - Search exhaustively finds all shortest paths.
  """
  @spec a_star_all(G.t(), G.coordinates(), G.coordinates()) :: Enumerable.t(AStar.path_info())
  @spec a_star_all(AStar.graph(), AStar.node_id(), term, module) ::
          Enumerable.t(AStar.path_info())
  defdelegate a_star_all(grid, start_coords, goal), to: AStar, as: :run

  def a_star_all(graph, start_node_id, goal, impl) do
    AStar.run(graph, start_node_id, goal, impl: impl)
  end

  @doc """
  Finds a shortest path with non-exhaustive search for improved performance.

  You may pass a callback module of the `AdventOfCode.Algo.AStar.Impl` behaviour to customize search behaviour.
  """
  @spec a_star_one(G.t(), G.coordinates(), G.coordinates()) :: {:ok, AStar.path_info()} | :error
  @spec a_star_one(AStar.graph(), AStar.node_id(), term, module) ::
          {:ok, AStar.path_info()} | :error
  def a_star_one(grid, start_coords, goal) do
    grid
    |> AStar.run(start_coords, goal, exhaustive?: false)
    |> Enum.fetch(0)
  end

  def a_star_one(graph, start_node_id, goal, impl) do
    graph
    |> AStar.run(start_node_id, goal, impl: impl, exhaustive?: false)
    |> Enum.fetch(0)
  end
end
