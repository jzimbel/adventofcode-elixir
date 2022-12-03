defmodule AdventOfCode.Solution.Year2022.Day01 do
  def part1(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&sum_inventory/1)
    |> Enum.max()
  end

  def part2(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&sum_inventory/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end

  defp sum_inventory(s) do
    s
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end
end
