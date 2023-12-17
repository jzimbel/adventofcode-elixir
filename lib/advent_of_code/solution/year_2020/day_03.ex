defmodule AdventOfCode.Solution.Year2020.Day03 do
  alias AdventOfCode.Grid

  def part1(args) do
    grid = Grid.from_input(args)

    run(grid, {3, 1})
  end

  @part2_slopes [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]

  def part2(args) do
    grid = Grid.from_input(args)

    @part2_slopes
    |> Enum.map(&run(grid, &1))
    |> Enum.reduce(&Kernel.*/2)
  end

  defp run(grid, slope), do: loop(grid, slope, {0, 0, 0})

  defp loop(grid, slope, state)

  defp loop(%{height: height}, _, {_, y, tree_count}) when y >= height do
    tree_count
  end

  defp loop(grid, {x_inc, y_inc} = slope, {x, y, tree_count}) do
    new_count =
      case Grid.at(grid, {x, y}) do
        ?# -> tree_count + 1
        ?. -> tree_count
      end

    loop(grid, slope, {rem(x + x_inc, grid.width), y + y_inc, new_count})
  end
end
