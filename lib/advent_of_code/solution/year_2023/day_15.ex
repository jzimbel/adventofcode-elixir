defmodule AdventOfCode.Solution.Year2023.Day15 do
  def part1(input), do: input |> parse() |> Stream.map(&hash/1) |> Enum.sum()
  def part2(input), do: input |> parse() |> to_map() |> stream_focusing_powers() |> Enum.sum()

  defp to_map(ops) do
    ops
    |> Stream.map(&Regex.run(~r/([^=]+)(?:-|=(.+))/, &1, capture: :all_but_first))
    |> Enum.reduce(Map.new(0..255, &{&1, []}), fn
      [i, f], m -> Map.update!(m, hash(i), &List.keystore(&1, i, 0, {i, String.to_integer(f)}))
      [i], m -> Map.update!(m, hash(i), &List.keydelete(&1, i, 0))
    end)
  end

  defp stream_focusing_powers(map) do
    Stream.flat_map(map, fn {box, lenses} ->
      lenses
      |> Stream.with_index(1)
      |> Stream.map(fn {{_label, f}, slot} -> (1 + box) * slot * f end)
    end)
  end

  defp hash(str), do: for(<<char <- str>>, reduce: 0, do: (acc -> rem((acc + char) * 17, 256)))
  defp parse(input), do: input |> String.split(",", trim: true) |> Stream.map(&String.trim/1)
end
