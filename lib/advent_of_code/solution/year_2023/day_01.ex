defmodule AdventOfCode.Solution.Year2023.Day01 do
  def part1(input), do: solve(input, &find_digit_part1/1)
  def part2(input), do: solve(input, &find_digit_part2/1)

  defp solve(input, finder_fn) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [find_first_digit(line, finder_fn), find_last_digit(line, finder_fn)]
      |> Integer.undigits()
    end)
    |> Enum.sum()
  end

  defguardp is_digit(char) when char in ?0..?9

  defp find_first_digit(<<_, rest::binary>> = str, finder_fn) do
    case finder_fn.(str) do
      {:ok, d} -> d
      :error -> find_first_digit(rest, finder_fn)
    end
  end

  defp find_last_digit(line, finder_fn), do: find_last_digit(line, finder_fn, byte_size(line) - 1)

  defp find_last_digit(line, finder_fn, drop_from_front) do
    <<_::binary-size(drop_from_front), str::binary>> = line

    case finder_fn.(str) do
      {:ok, d} -> d
      :error -> find_last_digit(line, finder_fn, drop_from_front - 1)
    end
  end

  defp find_digit_part1(<<char, _::binary>>) when is_digit(char), do: {:ok, char - ?0}
  defp find_digit_part1(_), do: :error

  defp find_digit_part2(<<char, _::binary>>) when is_digit(char), do: {:ok, char - ?0}
  defp find_digit_part2(str), do: find_leading_word_digit(str)

  for {str, n} <- Enum.zip(~w[one two three four five six seven eight nine], 1..9) do
    defp find_leading_word_digit(unquote(str) <> _), do: {:ok, unquote(n)}
  end

  defp find_leading_word_digit(_), do: :error
end
