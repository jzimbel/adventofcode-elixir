defmodule AdventOfCode.Solution.Year2021.Day10 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&corrupted_char/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&corrupted_score/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&incomplete_stack/1)
    |> Enum.reject(&match?('', &1))
    |> Enum.map(&autocomplete_score/1)
    |> Enum.sort()
    |> then(fn scores -> Enum.at(scores, div(length(scores), 2)) end)
  end

  defp corrupted_char(line, bracket_stack \\ '')

  defp corrupted_char('', _), do: nil

  for {open, close} <- [{?(, ?)}, {?[, ?]}, {?{, ?}}, {?<, ?>}] do
    defp corrupted_char([unquote(open) | rest_line], stack) do
      corrupted_char(rest_line, [unquote(close) | stack])
    end

    defp corrupted_char([unquote(close) | rest_line], [unquote(close) | rest_stack]) do
      corrupted_char(rest_line, rest_stack)
    end
  end

  defp corrupted_char([char | _], _), do: char

  defp incomplete_stack(line, bracket_stack \\ '')

  defp incomplete_stack('', stack), do: stack

  for {open, close} <- [{?(, ?)}, {?[, ?]}, {?{, ?}}, {?<, ?>}] do
    defp incomplete_stack([unquote(open) | rest_line], stack) do
      incomplete_stack(rest_line, [unquote(close) | stack])
    end

    defp incomplete_stack([unquote(close) | rest_line], [unquote(close) | rest_stack]) do
      incomplete_stack(rest_line, rest_stack)
    end
  end

  defp incomplete_stack([_ | _], _), do: ''

  defp corrupted_score(?)), do: 3
  defp corrupted_score(?]), do: 57
  defp corrupted_score(?}), do: 1197
  defp corrupted_score(?>), do: 25137

  defp autocomplete_score(stack) do
    Enum.reduce(stack, 0, fn char, acc -> acc * 5 + autocomplete_point_value(char) end)
  end

  defp autocomplete_point_value(?)), do: 1
  defp autocomplete_point_value(?]), do: 2
  defp autocomplete_point_value(?}), do: 3
  defp autocomplete_point_value(?>), do: 4

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
  end
end
