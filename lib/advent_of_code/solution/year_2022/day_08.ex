defmodule AdventOfCode.Solution.Year2022.Day08 do
  alias AdventOfCode.CharGrid

  def part1(input) do
    grid = CharGrid.from_input(input)

    interior_visible_count =
      for(
        x <- 1..(grid.width - 2)//1,
        y <- 1..(grid.height - 2)//1,
        do: {x, y}
      )
      |> Enum.map(&{CharGrid.at(grid, &1), CharGrid.lines_of_values(grid, &1, :cardinal)})
      |> Enum.count(fn {height, sight_lines} ->
        Enum.any?(sight_lines, fn heights ->
          Enum.all?(heights, &(&1 < height))
        end)
      end)

    perimeter_tree_count = 2 * grid.width + 2 * (grid.height - 2)

    interior_visible_count + perimeter_tree_count
  end

  def part2(input) do
    grid = CharGrid.from_input(input)

    for(
      x <- 1..(grid.width - 2)//1,
      y <- 1..(grid.height - 2)//1,
      do: {x, y}
    )
    |> Enum.map(&{CharGrid.at(grid, &1), CharGrid.lines_of_values(grid, &1, :cardinal)})
    |> Enum.map(&scenic_score/1)
    |> Enum.max()
  end

  defp scenic_score({height, sight_lines}) do
    sight_lines
    |> Enum.map(&count_visible(&1, height))
    |> Enum.product()
  end

  # A little tricky because we want to include the first tree that blocks our view.
  # All of the relevant `Enum` functions omit the first element that fails the condition,
  # so I needed to define my own recursive function.
  defp count_visible([], _), do: 0
  defp count_visible([tree | _trees], height) when tree >= height, do: 1
  defp count_visible([_tree | trees], height), do: 1 + count_visible(trees, height)
end
