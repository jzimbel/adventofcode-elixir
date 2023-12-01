defmodule AdventOfCode.Solution.Year2022.Day15 do
  def part1(input, check_y \\ 2_000_000) do
    guys = parse(input)

    exceptions = MapSet.new(for(%{b: {x, ^check_y}} <- guys, do: x))

    in_line =
      guys
      |> Enum.flat_map(&get_crossings(&1, check_y))
      |> MapSet.new()

    MapSet.size(MapSet.difference(in_line, exceptions))
  end

  def part2(_input, _search \\ 4_000_000) do
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_relation/1)
  end

  defp get_crossings(%{s: {x, y}, d: d}, check_y) do
    then(d - abs(y - check_y), &((x - &1)..(x + &1)//1))
  end

  defp parse_relation(line) do
    [sx, sy, bx, by] =
      ~r/-?\d+/
      |> Regex.scan(line)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)

    %{s: {sx, sy}, b: {bx, by}, d: dist({sx, sy}, {bx, by})}
  end

  defp dist({x, y}, {x2, y2}) do
    abs(x2 - x) + abs(y2 - y)
  end
end
