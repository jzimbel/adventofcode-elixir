defmodule AdventOfCode.Day06 do
  def part1(args) do
    count_yeses(args, &group_to_union_set/1)
  end

  def part2(args) do
    count_yeses(args, &group_to_intersection_set/1)
  end

  defp count_yeses(input, set_builder) do
    input
    |> parse_groups()
    |> Enum.map(set_builder)
    |> Enum.map(&MapSet.size/1)
    |> Enum.sum()
  end

  defp parse_groups(input) do
    input
    |> String.trim()
    |> String.split("\n\n")
  end

  defp group_to_union_set(group) do
    group
    |> String.replace(~r|[^a-z]|, "")
    |> String.to_charlist()
    |> MapSet.new()
  end

  defp group_to_intersection_set(group) do
    group
    |> String.split()
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.intersection/2)
  end
end
