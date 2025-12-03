defmodule AdventOfCode.Solution.Year2025.Day02 do
  use AdventOfCode.Solution.SharedParse

  import Integer, only: [is_odd: 1]

  @impl true
  def parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&parse_range/1)
  end

  defp parse_range(str) do
    ~r/(\d+)-(\d+)/
    |> Regex.run(str, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
    |> then(fn [first, last] -> first..last//1 end)
  end

  ####################
  # Part 1 functions #
  ####################

  def part1(ranges) do
    ranges
    |> Task.async_stream(&(&1 |> invalid_ids_p1() |> Enum.sum()), ordered: false)
    |> Enum.sum_by(fn {:ok, sum} -> sum end)
  end

  defp invalid_ids_p1(range) do
    range = clamp_range(range)
    exponent = exponent_of_10(range.first)
    splitter = Integer.pow(10, div(exponent, 2) + 1)
    Stream.filter(range, &(div(&1, splitter) == rem(&1, splitter)))
  end

  # Shrinks the range so that it contains only numbers with even numbers of digits.
  defp clamp_range(first..last//1) do
    clamp_up(first)..clamp_down(last)//1
  end

  # Note: In my input, none of the ranges are so large that they include numbers
  # within multiple odd exponents of 10, e.g. 10-1000.
  #
  # So clamping the single range is enough, ranges never need to be split into
  # multiple sub-ranges to remove even exponents of 10 in the middle.

  defp clamp_up(n) do
    exponent = exponent_of_10(n)
    if is_odd(exponent), do: n, else: Integer.pow(10, exponent + 1)
  end

  defp clamp_down(n) do
    exponent = exponent_of_10(n)
    if is_odd(exponent), do: n, else: Integer.pow(10, exponent) - 1
  end

  defp exponent_of_10(n), do: floor(:math.log10(n))

  ####################
  # Part 2 functions #
  ####################

  def part2(ranges) do
    ranges
    |> Task.async_stream(&(&1 |> invalid_ids_p2() |> Enum.sum()), ordered: false)
    |> Enum.sum_by(fn {:ok, sum} -> sum end)
  end

  defp invalid_ids_p2(range) do
    Stream.filter(range, &invalid_p2?/1)
  end

  defp invalid_p2?(n) do
    digits = Integer.digits(n)
    len = length(digits)

    # Generate chunk sizes to try splitting the digits up into
    1..div(len, 2)//1
    # Chunk size must divide the digits cleanly with no smaller leftover chunk at the end
    |> Stream.filter(&(div(len, &1) == len / &1))
    |> Enum.any?(fn chunk_size ->
      length(digits |> Enum.chunk_every(chunk_size) |> Enum.uniq()) == 1
    end)
  end
end
