defmodule AdventOfCode.Day01 do
  def part1(args) do
    args
    |> parse_input()
    |> find_two_addends(2020)
  end

  def part2(args) do
    nums = parse_input(args)

    indexed_nums = Enum.with_index(nums)

    find_three_addends(indexed_nums, nums, 2020)
  end

  defp parse_input(args) do
    args
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort()
  end

  defp find_two_addends(nums, target) do
    result =
      Enum.reduce_while(nums, MapSet.new(), fn n, found ->
        complement = target - n

        cond do
          complement > n -> {:cont, MapSet.put(found, n)}
          complement in found -> {:halt, {complement, n}}
          true -> {:cont, found}
        end
      end)

    case result do
      {a, b} -> a * b
      _ -> nil
    end
  end

  defp find_three_addends([{n, i} | rest], nums, target) do
    nums
    |> Enum.drop(i + 1)
    |> find_two_addends(target - n)
    |> case do
      nil -> find_three_addends(rest, nums, target)
      m -> n * m
    end
  end
end
