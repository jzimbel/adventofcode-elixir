defmodule AdventOfCode.Solution.Year2023.Day11 do
  alias AdventOfCode.Grid

  use AdventOfCode.Solution.SharedParse

  @impl true
  defdelegate parse(input), to: Grid, as: :from_input

  def part1(grid), do: solve(grid, 1)
  def part2(grid), do: solve(grid, 999_999)

  def solve(grid, spacing) do
    grid
    |> expanded_galaxy_coords(spacing)
    |> pairwise_distances_sum()
  end

  defp expanded_galaxy_coords(grid, spacing) do
    [new_xs, new_ys] =
      Task.await_many([
        Task.async(fn -> expanded_axis(grid, spacing, &Grid.cols/1, fn {x, _y} -> x end) end),
        Task.async(fn -> expanded_axis(grid, spacing, &Grid.rows/1, fn {_x, y} -> y end) end)
      ])

    Enum.map(new_xs, fn {coords, x} -> {x, new_ys[coords]} end)
  end

  defp expanded_axis(grid, spacing, lanes_fn, axis_fn) do
    grid
    |> lanes_fn.()
    |> Enum.flat_map_reduce(0, fn lane, expand_by ->
      if Enum.all?(lane, &match?({_coords, ?.}, &1)) do
        {[], expand_by + spacing}
      else
        {for({coords, ?#} <- lane, do: {coords, axis_fn.(coords) + expand_by}), expand_by}
      end
    end)
    |> then(fn {new_axis, _expand_by} -> Map.new(new_axis) end)
  end

  defp pairwise_distances_sum(galaxy_coords, sum \\ 0)
  defp pairwise_distances_sum([], sum), do: sum

  defp pairwise_distances_sum([{x1, y1} | rest], sum) do
    new_sums = for({x2, y2} <- rest, reduce: 0, do: (acc -> acc + abs(x2 - x1) + abs(y2 - y1)))
    pairwise_distances_sum(rest, sum + new_sums)
  end
end
