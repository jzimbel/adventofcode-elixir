defmodule AdventOfCode.Solution.Year2020.Day09 do
  @preamble_length 25

  def part1(args, preamble_length \\ @preamble_length) do
    {preamble, nums} =
      args
      |> parse_nums()
      |> split_preamble(preamble_length)

    find_invalid(nums, preamble, preamble_length)
  end

  def part2(args, preamble_length \\ @preamble_length) do
    full_nums = parse_nums(args)

    {preamble, nums} = split_preamble(full_nums, preamble_length)

    target = find_invalid(nums, preamble, preamble_length)

    addends = find_contiguous_addends(full_nums, target)

    Enum.min(addends) + Enum.max(addends)
  end

  defp parse_nums(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  defp split_preamble(nums, preamble_length) do
    {preamble, nums} = Enum.split(nums, preamble_length)

    {Enum.reverse(preamble), nums}
  end

  defp find_invalid(nums, preamble, preamble_length) do
    nums
    |> Stream.transform(preamble, fn n, prev ->
      {[{Stream.take(prev, preamble_length), n}], [n | prev]}
    end)
    |> Stream.reject(fn {prev, n} -> addends_exist?(prev, n) end)
    |> Enum.at(0)
    |> elem(1)
  end

  defp addends_exist?(nums, target) do
    nums
    |> Stream.transform(MapSet.new(), fn n, found ->
      {[{n, found}], MapSet.put(found, n)}
    end)
    |> Enum.any?(fn {n, found} -> (target - n) in found end)
  end

  defp find_contiguous_addends(nums, target) do
    2..length(nums)
    |> Stream.map(&find_contiguous_addends(nums, target, &1))
    |> Stream.reject(&is_nil/1)
    |> Enum.at(0)
  end

  defp find_contiguous_addends(nums, target, window_size) do
    nums
    |> Stream.chunk_every(window_size, 1)
    |> Enum.find(&(Enum.sum(&1) == target))
  end
end
