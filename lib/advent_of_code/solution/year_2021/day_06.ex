defmodule AdventOfCode.Solution.Year2021.Day06 do
  def part1(input) do
    input
    |> parse_input()
    |> get_population_on_day(80)
  end

  def part2(input) do
    input
    |> parse_input()
    |> get_population_on_day(256)
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies()
  end

  defp get_population_on_day(initial_ages, day) do
    initial_ages
    |> Stream.iterate(&next_day/1)
    |> Enum.at(day)
    |> Map.values()
    |> Enum.sum()
  end

  defp next_day(ages) do
    ages
    |> Enum.flat_map(fn
      {0, count} -> [{6, count}, {8, count}]
      {n, count} -> [{n - 1, count}]
    end)
    |> Enum.group_by(fn {age, _} -> age end, fn {_, count} -> count end)
    |> Enum.map(fn {age, counts} -> {age, Enum.sum(counts)} end)
    |> Enum.into(%{})
  end
end
