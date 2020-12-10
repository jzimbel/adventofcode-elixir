defmodule AdventOfCode.Day09 do
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
    Enum.reduce_while(nums, preamble, fn n, prev ->
      prev
      |> Stream.take(preamble_length)
      |> addends_exist?(n)
      |> case do
        true -> {:cont, [n | prev]}
        false -> {:halt, n}
      end
    end)
  end

  defp addends_exist?(nums, target) do
    nums
    |> Enum.reduce_while(MapSet.new(), fn n, found ->
      cond do
        (target - n) in found -> {:halt, :exists}
        true -> {:cont, MapSet.put(found, n)}
      end
    end)
    |> case do
      :exists -> true
      _ -> false
    end
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
