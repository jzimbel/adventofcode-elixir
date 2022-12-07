defmodule AdventOfCode.Solution.Year2022.Day06 do
  def part1(input), do: index_of_marker(input, 4)
  def part2(input), do: index_of_marker(input, 14)

  defp index_of_marker(input, size) do
    input
    |> String.to_charlist()
    |> Stream.chunk_every(size, 1, :discard)
    |> Enum.find_index(&(MapSet.size(MapSet.new(&1)) == size))
    |> Kernel.+(size)
  end
end
