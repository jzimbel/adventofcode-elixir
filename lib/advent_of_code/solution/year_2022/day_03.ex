defmodule AdventOfCode.Solution.Year2022.Day03 do
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&find_duplicate/1)
    |> Enum.map(&priority/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(&find_badge/1)
    |> Enum.map(&priority/1)
    |> Enum.sum()
  end

  defp find_duplicate(sack) do
    compartment_size = div(byte_size(sack), 2)

    sack
    |> String.to_charlist()
    |> Enum.split(compartment_size)
    |> then(fn {l, r} -> MapSet.intersection(MapSet.new(l), MapSet.new(r)) end)
    |> Enum.at(0)
  end

  defp find_badge(group) do
    group
    |> Enum.map(&(&1 |> String.to_charlist() |> MapSet.new()))
    |> Enum.reduce(&MapSet.intersection/2)
    |> Enum.at(0)
  end

  for {item, pri} <- Enum.with_index(Enum.concat(?a..?z, ?A..?Z), 1) do
    defp priority(unquote(item)), do: unquote(pri)
  end
end
