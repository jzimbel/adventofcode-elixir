defmodule AdventOfCode.Algo do
  @moduledoc """
  Pathfinding and other algorithm implementations.
  """
  alias AdventOfCode.Algo.AStar
  alias AdventOfCode.Grid, as: G

  @doc """
  A* search over a Grid.

  Returns a stream that emits `{path, cost}` pairs for all shortest paths in the grid.

  You may pass a callback module of the `AdventOfCode.Algo.AStar.Impl` behaviour to customize search behaviour.

  Default behaviour:
  - Searches a Grid with char values.
  - Cells with ?. values are considered reachable. All others are unreachable.
  - A cell's neighbors are its cardinally adjacent ?.-valued cells.
  - Distance to a neighbor is always 1.
  - Heuristic is Manhattan distance.
  """
  @spec a_star(G.t(), AStar.State.t(), G.coordinates()) :: Enumerable.t(AStar.path_info())
  @spec a_star(G.t(), AStar.State.t(), term, module) :: Enumerable.t(AStar.path_info())
  defdelegate a_star(grid, start, goal), to: AStar, as: :run
  defdelegate a_star(grid, start, goal, impl), to: AStar, as: :run
end
