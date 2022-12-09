defmodule AdventOfCode.Solution.Year2022.Day08 do
  alias AdventOfCode.CharGrid

  def part1(input) do
    {grid, sight_lines_by_tree} = parse(input)

    interior_visible_count = Enum.count(sight_lines_by_tree, &visible?/1)
    perimeter_tree_count = 2 * grid.width + 2 * (grid.height - 2)

    interior_visible_count + perimeter_tree_count
  end

  def part2(input) do
    {_grid, sight_lines_by_tree} = parse(input)

    sight_lines_by_tree
    |> Enum.map(&scenic_score/1)
    |> Enum.max()
  end

  defp parse(input) do
    grid = CharGrid.from_input(input)

    sight_lines_by_tree =
      for(
        # Trees on the perimeter are excluded
        x <- 1..(grid.width - 2)//1,
        y <- 1..(grid.height - 2)//1,
        do: {x, y}
      )
      |> Enum.map(&{CharGrid.at(grid, &1), CharGrid.lines_of_values(grid, &1, :cardinal)})

    {grid, sight_lines_by_tree}
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
