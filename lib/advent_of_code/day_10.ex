defmodule AdventOfCode.Day10 do
  def part1(args) do
    args
    |> parse_adapters()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.frequencies_by(fn [a, b] -> b - a end)
    |> Map.take([1, 3])
    |> Map.values()
    |> Enum.reduce(&Kernel.*/2)
  end

  def part2(args) do
    args
    |> parse_adapters()
    # Skip the 0-jolt outlet and just init the accumulator with its (known)
    # result since it would require a special case in the reducer function.
    |> Enum.drop(1)
    |> Enum.reduce({1, %{0 => 1}}, fn n, {_, prev_counts} ->
      path_count =
        prev_counts
        |> Map.take([n - 3, n - 2, n - 1])
        |> Map.values()
        |> Enum.sum()

      {path_count, Map.put(prev_counts, n, path_count)}
    end)
    |> elem(0)
  end

  defp parse_adapters(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> add_outlet_and_builtin()
    |> Enum.sort()
  end

  defp add_outlet_and_builtin(adapters) do
    [0, Enum.max(adapters) + 3 | adapters]
  end
end
