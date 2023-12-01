defmodule AdventOfCode.Solution.Year2023.Day01 do
  def part1(input), do: solve(input, &digits_part1/1)

  def part2(input), do: solve(input, &digits_part2/1)

  defp solve(input, get_digits_fn) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> get_digits_fn.()
      |> then(fn digits ->
        [List.first(digits), List.last(digits)]
        |> Integer.undigits()
      end)
    end)
    |> Enum.sum()
  end

  defp digits_part1(line, acc \\ [])

  defp digits_part1("", acc), do: Enum.reverse(acc)

  defp digits_part1(<<n, rest::binary>>, acc) when n in ?0..?9 do
    digits_part1(rest, [n - ?0 | acc])
  end

  defp digits_part1(<<_, rest::binary>>, acc) do
    digits_part1(rest, acc)
  end

  ###

  defp digits_part2(line, acc \\ [])

  defp digits_part2("", acc), do: Enum.reverse(acc)

  defp digits_part2(<<n, rest::binary>>, acc) when n in ?0..?9 do
    digits_part2(rest, [n - ?0 | acc])
  end

  defp digits_part2(<<_, rest::binary>> = line, acc) do
    acc =
      case lookup(line) do
        {:ok, digit} -> [digit | acc]
        :error -> acc
      end

    digits_part2(rest, acc)
  end

  spelled_out = %{
    "one" => 1,
    "two" => 2,
    "three" => 3,
    "four" => 4,
    "five" => 5,
    "six" => 6,
    "seven" => 7,
    "eight" => 8,
    "nine" => 9
  }

  for {str, n} <- spelled_out do
    defp lookup(unquote(str) <> _), do: {:ok, unquote(n)}
  end

  defp lookup(_), do: :error
end
