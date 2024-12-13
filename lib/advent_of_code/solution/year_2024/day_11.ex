defmodule AdventOfCode.Solution.Year2024.Day11 do
  use AdventOfCode.Solution.SharedParse

  import Integer, only: [is_even: 1]

  @impl true
  def parse(input) do
    for {stone, n} <- Enum.frequencies(String.split(input)), do: {String.to_integer(stone), n}
  end

  def part1(stones), do: solve(stones, 25)
  def part2(stones), do: solve(stones, 75)

  defp solve(stones, blinks) do
    stones
    |> Stream.iterate(&blink/1)
    |> Enum.at(blinks)
    |> Enum.map(fn {_stone, n} -> n end)
    |> Enum.sum()
  end

  defp blink(stones) do
    stones
    |> Enum.flat_map(fn {stone, n} ->
      cond do
        stone == 0 ->
          [{1, n}]

        is_even(n_digits = trunc(:math.log10(stone)) + 1) ->
          divisor = Integer.pow(10, div(n_digits, 2))
          [{rem(stone, divisor), n}, {div(stone, divisor), n}]

        true ->
          [{stone * 2024, n}]
      end
    end)
    |> collect()
  end

  defp collect(stones) do
    stones
    |> Enum.group_by(fn {stone, _n} -> stone end, fn {_stone, n} -> n end)
    |> Enum.map(fn {stone, ns} -> {stone, Enum.sum(ns)} end)
  end
end
