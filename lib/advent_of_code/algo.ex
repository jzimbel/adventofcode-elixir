defmodule AdventOfCode.Algo do
  @moduledoc """
  Pathfinding and other algorithm implementations.
  """
  alias AdventOfCode.Algo.AStar
  alias AdventOfCode.Grid, as: G

  @spec a_star(G.t(), G.coordinates(), G.coordinates()) :: {:ok, list(G.coordinates())} | :error
  @spec a_star(G.t(), G.coordinates(), G.coordinates(), heuristic) ::
          {:ok, list(G.coordinates())} | :error
        when heuristic: (G.coordinates(), G.coordinates() -> integer)
  defdelegate a_star(grid, start, goal, heuristic), to: AStar, as: :run
  defdelegate a_star(grid, start, goal), to: AStar, as: :run
end
