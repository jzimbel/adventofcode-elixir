defmodule AdventOfCode.Solution.Year2023.Day06 do
  import Integer, only: [is_even: 1]

  def part1(input) do
    input
    |> parse_p1()
    |> Enum.map(&count_wins/1)
    |> Enum.product()
  end

  def part2(input) do
    input
    |> parse_p2()
    |> count_wins()
  end

  defp parse_p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
  end

  defp parse_p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(":")
      |> Enum.at(1)
      |> String.replace(" ", "")
      |> String.to_integer()
    end)
    |> List.to_tuple()
  end

  defp count_wins({t, d}) do
    half_t = div(t, 2)
    n = binary_search_first_win(1, half_t, t, d)

    if is_even(t), do: 2 * (half_t - n) + 1, else: 2 * (half_t - n + 1)
  end

  defp binary_search_first_win(n_min, n_max, t, d) do
    n = div(n_min + n_max, 2)

    with {:n_wins_race?, true} <- {:n_wins_race?, n * (t - n) > d},
         n_sub1 = n - 1,
         {:n_sub1_loses_race?, true} <- {:n_sub1_loses_race?, n_sub1 * (t - n_sub1) <= d} do
      n
    else
      {:n_wins_race?, false} -> binary_search_first_win(n + 1, n_max, t, d)
      {:n_sub1_loses_race?, false} -> binary_search_first_win(n_min, n - 1, t, d)
    end
  end
end
