defmodule AdventOfCode.Solution.Year2023.Day09 do
  def part1(input) do
    input
    |> parse_reverse()
    |> Enum.map(&extrapolate_forward/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse()
    |> Enum.map(&extrapolate_backward/1)
    |> Enum.sum()
  end

  defp extrapolate_forward(values, acc \\ 0)

  defp extrapolate_forward(values, acc) do
    if Enum.all?(values, &(&1 == 0)) do
      acc
    else
      values
      |> Enum.chunk_every(2, 1, :discard)
      # (List is reversed, so diff is left-right rather than right-left.)
      |> Enum.map(fn [b, a] -> b - a end)
      |> extrapolate_forward(acc + hd(values))
    end
  end

  defp extrapolate_backward(values)

  defp extrapolate_backward(values) do
    if Enum.all?(values, &(&1 == 0)) do
      0
    else
      sub_result =
        values
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.map(fn [a, b] -> b - a end)
        |> extrapolate_backward()

      hd(values) - sub_result
    end
  end

  defp parse_reverse(input) do
    for line <- String.split(input, "\n", trim: true) do
      line
      |> String.split()
      |> Stream.map(&String.to_integer/1)
      |> Enum.reverse()
    end
  end

  defp parse(input) do
    for line <- String.split(input, "\n", trim: true) do
      for num <- String.split(line), do: String.to_integer(num)
    end
  end
end
