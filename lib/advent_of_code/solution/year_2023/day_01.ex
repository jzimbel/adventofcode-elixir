defmodule AdventOfCode.Solution.Year2023.Day01 do
  def part1(input), do: solve(input, &digits_part1/1)

  def part2(input), do: solve(input, &digits_part2/1)

  defp solve(input, get_digits_fn) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&(&1 |> get_digits_fn.() |> Integer.undigits()))
    |> Enum.sum()
  end

  defp digits_part1(line, acc \\ [])

  defp digits_part1("", acc), do: [List.first(acc), List.last(acc)]

  defp digits_part1(<<n, rest::binary>>, acc) when n in ?0..?9 do
    digits_part1(rest, put_digit(acc, n - ?0))
  end

  defp digits_part1(<<_, rest::binary>>, acc) do
    digits_part1(rest, acc)
  end

  ###

  defp digits_part2(line, acc \\ [])

  defp digits_part2("", acc), do: [List.first(acc), List.last(acc)]

  defp digits_part2(<<n, rest::binary>>, acc) when n in ?0..?9 do
    digits_part2(rest, put_digit(acc, n - ?0))
  end

  defp digits_part2(<<_, rest::binary>> = line, acc) do
    acc =
      case lookup(line) do
        {:ok, digit} -> put_digit(acc, digit)
        :error -> acc
      end

    digits_part2(rest, acc)
  end

  defp put_digit([], first_digit), do: [first_digit]
  defp put_digit([first_digit | _], digit), do: [first_digit, digit]

  for {str, n} <- Enum.zip(~w[one two three four five six seven eight nine], 1..9) do
    defp lookup(unquote(str) <> _), do: {:ok, unquote(n)}
  end

  defp lookup(_), do: :error
end
