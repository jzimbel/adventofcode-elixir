defmodule AdventOfCode.Solution.Year2022.Day08 do
  alias AdventOfCode.CharGrid

  def part1(input) do
    input
    |> parse_sight_lines_by_tree()
    |> Enum.count(&visible?/1)
  end

  def part2(input) do
    input
    |> parse_sight_lines_by_tree()
    |> Enum.map(&scenic_score/1)
    |> Enum.max()
  end

  defp parse_sight_lines_by_tree(input) do
    grid = CharGrid.from_input(input)

    grid
    |> CharGrid.to_list()
    |> Enum.map(fn {coords, tree} ->
      {tree, CharGrid.lines_of_values(grid, coords, :cardinal)}
    end)
  end

  defp visible?({tree, sight_lines}) do
    Enum.any?(sight_lines, fn other_trees ->
      Enum.all?(other_trees, &(&1 < tree))
    end)
  end

  defp scenic_score({tree, sight_lines}) do
    sight_lines
    |> Enum.map(&count_visible(&1, tree))
    |> Enum.product()
  end

  # A little tricky because we want to include the first tree that blocks our view.
  # All of the relevant `Enum` functions omit the first element that fails the condition,
  # so I needed to define my own recursive function.
  defp count_visible([], _), do: 0
  defp count_visible([tree | _trees], from_tree) when tree >= from_tree, do: 1
  defp count_visible([_tree | trees], from_tree), do: 1 + count_visible(trees, from_tree)
end
