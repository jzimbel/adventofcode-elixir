defmodule AdventOfCode.Solution.Year2020.Day07 do
  @my_bag "shiny gold"

  def part1(args) do
    args
    |> parse_rules()
    |> count_reachable(@my_bag)
  end

  def part2(args) do
    args
    |> parse_rules()
    |> count_bags(@my_bag)
  end

  defp parse_rules(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.into(%{}, &parse_rule/1)
  end

  defp parse_rule(line) do
    line
    |> String.split(" bags contain ")
    |> parse_contents()
  end

  defp parse_contents([color, "no other bags."]), do: {color, []}

  defp parse_contents([color, contents]) do
    rules =
      contents
      |> String.trim_trailing(".")
      |> String.split(", ")
      |> Enum.map(&Regex.run(~r/(\d+) (\w+ \w+)/, &1, capture: :all_but_first))
      |> Enum.map(fn [num, color] -> {color, String.to_integer(num)} end)

    {color, rules}
  end

  defp count_reachable(rules, target_color) do
    rules
    |> Map.delete(target_color)
    |> Map.keys()
    |> Enum.count(&reachable?(rules, rules[&1], target_color))
  end

  defp reachable?(_, [], _), do: false

  defp reachable?(rules, current_rule, target_color) do
    colors = MapSet.new(current_rule, fn {c, _n} -> c end)

    MapSet.member?(colors, target_color) or
      Enum.any?(colors, &reachable?(rules, rules[&1], target_color))
  end

  defp count_bags(rules, target_color) do
    rules[target_color]
    |> Enum.map(fn {color, num} -> num + num * count_bags(rules, color) end)
    |> Enum.sum()
  end
end
