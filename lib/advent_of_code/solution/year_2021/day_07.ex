defmodule AdventOfCode.Solution.Year2021.Day07 do
  def part1(input) do
    input
    |> parse_input()
    |> find_min_fuel_consumption(&fuel_consumption_a/2)
  end

  def part2(input) do
    input
    |> parse_input()
    |> find_min_fuel_consumption(&fuel_consumption_b/2)
  end

  defp find_min_fuel_consumption(locs, consumption_fn) do
    Enum.min(locs)..Enum.max(locs)
    |> Enum.map(&consumption_fn.(locs, &1))
    |> Enum.min()
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp fuel_consumption_a(locs, position) do
    locs
    |> Enum.map(&abs(&1 - position))
    |> Enum.sum()
  end

  defp fuel_consumption_b(locs, position) do
    locs
    |> Enum.map(fn loc ->
      n = abs(loc - position)

      # Math!! 1 + 2 + ... + n == n(n+1)/2
      div(n * (n + 1), 2)
    end)
    |> Enum.sum()
  end
end
