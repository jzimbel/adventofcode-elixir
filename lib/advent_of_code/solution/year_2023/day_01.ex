defmodule AdventOfCode.Solution.Year2023.Day01 do
  def part1(input), do: solve(input, &digits_part1/1)
  def part2(input), do: solve(input, &digits_part2/1)

  defp solve(input, get_digits_fn) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&(&1 |> get_digits_fn.() |> Integer.undigits()))
    |> Enum.sum()
  end

  defguardp is_digit(char) when char in ?0..?9

  defp digits_part1(line, acc \\ [])
  defp digits_part1("", acc), do: [List.first(acc), List.last(acc)]

  defp digits_part1(<<char, rest::binary>>, acc) when is_digit(char) do
    digits_part1(rest, put_digit(acc, char - ?0))
  end

  defp digits_part1(<<_, rest::binary>>, acc) do
    digits_part1(rest, acc)
  end

  ###

  defp digits_part2(line, acc \\ [])
  defp digits_part2("", acc), do: [List.first(acc), List.last(acc)]

  defp digits_part2(<<char, rest::binary>>, acc) when is_digit(char) do
    digits_part2(rest, put_digit(acc, char - ?0))
  end

  defp digits_part2(<<_, rest::binary>> = line, acc) do
    acc =
      case find_leading_word_digit(line) do
        {:ok, digit} -> put_digit(acc, digit)
        :error -> acc
      end

    digits_part2(rest, acc)
  end

  defp put_digit([], first_digit), do: [first_digit]
  defp put_digit([first_digit | _], digit), do: [first_digit, digit]

  for {str, n} <- Enum.zip(~w[one two three four five six seven eight nine], 1..9) do
    defp find_leading_word_digit(unquote(str) <> _), do: {:ok, unquote(n)}
  end

  defp find_leading_word_digit(_), do: :error
end
