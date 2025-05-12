defmodule AdventOfCode.Solution.Year2024.Day18 do
  alias AdventOfCode.Algo
  alias AdventOfCode.Grid, as: G

  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input, grid_size \\ 71) do
    grid = G.new(grid_size, grid_size)

    drops =
      for line <- String.split(input, "\n", trim: true) do
        [x, y] = for n <- String.split(line, ","), do: String.to_integer(n)
        {x, y}
      end

    {grid, drops}
  end

  def part1({grid, drops}, t \\ 1024) do
    grid =
      drops
      |> Enum.take(t)
      |> Enum.reduce(grid, &G.replace(&2, &1, ?#))

    {:ok, path} = Algo.a_star(grid, {0, 0}, {grid.width - 1, grid.height - 1})
    steps = length(path) - 1
    steps
  end

  def part2({grid, drops}) do
    {x, y} = find_blocker(grid, drops)
    "#{x},#{y}"
  end

  defp find_blocker(grid, drops, prev_path \\ nil, prev_drop \\ nil)

  defp find_blocker(grid, [drop | drops], prev_path, prev_drop) do
    if is_nil(prev_path) or Enum.any?(prev_path, &(G.at(grid, &1) == ?#)) do
      case Algo.a_star(grid, {0, 0}, {grid.width - 1, grid.height - 1}) do
        {:ok, path} -> find_blocker(G.replace(grid, drop, ?#), drops, path, drop)
        :error -> prev_drop
      end
    else
      find_blocker(G.replace(grid, drop, ?#), drops, prev_path, drop)
    end
  end

  # No drops left to apply, but we haven't checked whether the final drop blocked the path
  defp find_blocker(grid, [], prev_path, prev_drop) do
    if is_nil(prev_path) or Enum.any?(prev_path, &(G.at(grid, &1) == ?#)) do
      case Algo.a_star(grid, {0, 0}, {grid.width - 1, grid.height - 1}) do
        {:ok, _path} -> :error
        :error -> prev_drop
      end
    else
      :error
    end
  end
end
