defmodule AdventOfCode.Solution.Year2024.Day08 do
  use AdventOfCode.Solution.SharedParse

  alias AdventOfCode.Grid, as: G

  @impl true
  def parse(input), do: G.from_input(input)

  def part1(grid), do: solve(grid, &Enum.slice(&1, 1, 1))
  def part2(grid), do: solve(grid)

  defp solve(grid, stream_limiter \\ &Function.identity/1) do
    grid
    |> antenna_groups()
    |> Enum.map(&antinode_streams/1)
    |> List.flatten()
    |> Enum.map(stream_limiter)
    |> Enum.flat_map(fn s -> Enum.take_while(s, &G.in_bounds?(grid, &1)) end)
    |> MapSet.new()
    |> MapSet.size()
  end

  defp antenna_groups(grid) do
    grid
    |> G.filter_cells(fn {_coords, char} -> char != ?. end)
    |> Enum.group_by(
      fn {_coords, char} -> char end,
      fn {coords, _char} -> coords end
    )
    |> Map.values()
  end

  # Produces pairs of streams that step outward from 2 antennae, forever
  defp antinode_streams(coords) do
    for {c1, i} <- Enum.with_index(coords), c2 <- Enum.drop(coords, i + 1) do
      diff_forwards = subtract(c2, c1)
      diff_backwards = invert(diff_forwards)

      [
        Stream.iterate(c2, &add(&1, diff_forwards)),
        Stream.iterate(c1, &add(&1, diff_backwards))
      ]
    end
  end

  defp add({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}
  defp subtract({x1, y1}, {x2, y2}), do: {x1 - x2, y1 - y2}
  defp invert({x, y}), do: {-x, -y}
end
