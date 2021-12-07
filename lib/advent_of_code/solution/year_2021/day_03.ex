defmodule AdventOfCode.Solution.Year2021.Day03 do
  def part1(input) do
    frequencies = parse_frequencies(input)

    gamma = select_bits_by_frequency(frequencies, &Enum.max_by/2)
    epsilon = select_bits_by_frequency(frequencies, &Enum.min_by/2)

    gamma * epsilon
  end

  def part2(input) do
    nums = parse_nums(input)

    o2_rating = filter_nums_by_frequency(nums, &Enum.max_by/2, ?1)
    co2_rating = filter_nums_by_frequency(nums, &Enum.min_by/2, ?0)

    o2_rating * co2_rating
  end

  defp parse_nums(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
  end

  defp parse_frequencies(input) do
    input
    |> parse_nums()
    |> get_frequencies()
  end

  defp get_frequencies(nums) do
    nums
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.frequencies/1)
  end

  defp select_bits_by_frequency(frequencies, frequency_selector) do
    frequencies
    |> Enum.map(fn freqs -> frequency_selector.(freqs, &elem(&1, 1)) end)
    |> Enum.map(&elem(&1, 0))
    |> to_string()
    |> String.to_integer(2)
  end

  defp filter_nums_by_frequency(nums, column \\ 0, frequency_selector, tiebreaker)

  defp filter_nums_by_frequency([num], _, _, _) do
    num
    |> to_string()
    |> String.to_integer(2)
  end

  defp filter_nums_by_frequency(nums, column, frequency_selector, tiebreaker) do
    frequencies = get_frequencies(nums)

    filter_digit =
      case Enum.at(frequencies, column) do
        %{?0 => n, ?1 => n} ->
          tiebreaker

        freqs ->
          freqs
          |> frequency_selector.(&elem(&1, 1))
          |> elem(0)
      end

    nums = Enum.filter(nums, &(Enum.at(&1, column) == filter_digit))

    column = rem(column + 1, length(hd(nums)))

    filter_nums_by_frequency(nums, column, frequency_selector, tiebreaker)
  end
end
