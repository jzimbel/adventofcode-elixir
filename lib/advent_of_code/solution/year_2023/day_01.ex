defmodule AdventOfCode.Solution.Year2023.Day01 do
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.flat_map(fn c ->
        case Integer.parse(c) do
          {n, ""} -> [n]
          _ -> []
        end
      end)
      |> then(fn digits ->
        [List.first(digits), List.last(digits)]
        |> Integer.undigits()
      end)
    end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&do_it/1)
    |> Enum.sum()
  end

  defp do_it(line, acc \\ [])

  defp do_it("", acc) do
    acc
    |> Enum.reverse()
    |> then(fn digits ->
      [List.first(digits), List.last(digits)]
      |> Integer.undigits()
    end)
  end

  defp do_it(<<n, rest::binary>>, acc) when n in ?0..?9 do
    do_it(rest, [n - ?0 | acc])
  end

  defp do_it(line, acc) do
    case lookup(line) do
      {:ok, n, _char_count} ->
        <<_, rest::binary>> = line
        do_it(rest, [n | acc])

      :error ->
        <<_, rest::binary>> = line
        do_it(rest, acc)
    end
  end

  @spelled_out %{
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

  for {str, n} <- @spelled_out do
    char_count = String.length(str)

    defp lookup(unquote(str) <> _), do: {:ok, unquote(n), unquote(char_count)}
  end

  defp lookup(_), do: :error
end
