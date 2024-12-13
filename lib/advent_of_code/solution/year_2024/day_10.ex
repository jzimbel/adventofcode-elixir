defmodule AdventOfCode.Solution.Year2024.Day10 do
  use AdventOfCode.Solution.SharedParse

  alias AdventOfCode.Grid, as: G

  @impl true
  def parse(input), do: G.from_input(input)

  def part1(grid), do: solve(grid, true)
  def part2(grid), do: solve(grid, false)

  defp solve(grid, uniq?) do
    for {point, ?0} <- grid, reduce: 0 do
      acc -> acc + count_trailheads([point], ?1, grid, uniq?)
    end
  end

  defp count_trailheads(points, ?9, grid, uniq?) do
    length(next(points, ?9, grid, uniq?))
  end

  defp count_trailheads(points, target, grid, uniq?) do
    count_trailheads(next(points, target, grid, uniq?), target + 1, grid, uniq?)
  end

  defp next(points, target, grid, uniq?) do
    next_points =
      for point <- points,
          {next_point, ^target} <- G.adjacent_cells(grid, point, :cardinal) do
        next_point
      end

    if uniq?, do: Enum.uniq(next_points), else: next_points
  end
end
