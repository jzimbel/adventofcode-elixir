defmodule AdventOfCode.Solution.Year2022.Day04 do
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_ints/1)
    |> Enum.count(&superset_subset?/1)
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_ints/1)
    |> Enum.count(&overlap?/1)
  end

  defp parse_ints(line) do
    ~r/^(\d+)-(\d+),(\d+)-(\d+)$/
    |> Regex.run(line, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
  end

  defp superset_subset?([a, b, x, y]) do
    (a <= x and b >= y) or (a >= x and b <= y)
  end

  defp overlap?([a, b, x, y]) do
    not Range.disjoint?(a..b, x..y)
  end
end
