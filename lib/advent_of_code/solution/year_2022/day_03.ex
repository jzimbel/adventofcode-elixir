defmodule AdventOfCode.Solution.Year2022.Day03 do
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&duplicate_item_priority/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(&common_char_priority/1)
    |> Enum.sum()
  end

  defp duplicate_item_priority(sack) do
    compartment_size = div(byte_size(sack), 2)
    <<l::binary-size(compartment_size), r::binary>> = sack
    common_char_priority([l, r])
  end

  defp common_char_priority(strings) do
    strings
    |> Enum.map(&(&1 |> String.to_charlist() |> MapSet.new()))
    |> Enum.reduce(&MapSet.intersection/2)
    |> Enum.at(0)
    |> priority()
  end

  for {item, pri} <- Enum.with_index(Enum.concat(?a..?z, ?A..?Z), 1) do
    defp priority(unquote(item)), do: unquote(pri)
  end
end
