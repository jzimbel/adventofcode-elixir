defmodule AdventOfCode.Solution.Year2022.Day02 do
  @scores %{
    "A X" => {3 + 1, 0 + 3},
    "A Y" => {6 + 2, 3 + 1},
    "A Z" => {0 + 3, 6 + 2},
    "B X" => {0 + 1, 0 + 1},
    "B Y" => {3 + 2, 3 + 2},
    "B Z" => {6 + 3, 6 + 3},
    "C X" => {6 + 1, 0 + 2},
    "C Y" => {0 + 2, 3 + 3},
    "C Z" => {3 + 3, 6 + 1}
  }

  def part1(input), do: total_score(input, 0)

  def part2(input), do: total_score(input, 1)

  defp total_score(input, lookup_column, score \\ 0)

  defp total_score(<<round::binary-size(3), ?\n, rest::binary>>, lookup_column, score) do
    total_score(rest, lookup_column, score + elem(@scores[round], lookup_column))
  end

  defp total_score("", _, score), do: score
end
