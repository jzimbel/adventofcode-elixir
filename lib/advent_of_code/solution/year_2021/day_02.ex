defmodule AdventOfCode.Solution.Year2021.Day02 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.reduce({0, 0}, fn command, {x, y} ->
      case command do
        {:forward, n} -> {x + n, y}
        {:down, n} -> {x, y + n}
        {:up, n} -> {x, y - n}
      end
    end)
    |> Tuple.product()
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.reduce({0, 0, 0}, fn command, {x, y, a} ->
      case command do
        {:forward, n} -> {x + n, y + n * a, a}
        {:down, n} -> {x, y, a + n}
        {:up, n} -> {x, y, a - n}
      end
    end)
    |> Tuple.delete_at(2)
    |> Tuple.product()
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [command, value] -> {String.to_atom(command), String.to_integer(value)} end)
  end
end
