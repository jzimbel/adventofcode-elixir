defmodule AdventOfCode.Solution.Year2025.Day05 do
  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input) do
    [ranges, ids] = String.split(input, "\n\n")
    {parse_and_consolidate_ranges(ranges), parse_ids(ids)}
  end

  def part1({ranges, ids}),
    do: Enum.count(ids, fn id -> Enum.any?(ranges, &in_range_fast?(&1, id)) end)

  def part2({ranges, _ids}), do: Enum.sum_by(ranges, &Range.size/1)

  defp consolidate(ranges) do
    [first_range | ranges] = Enum.sort_by(ranges, & &1.first)

    Enum.chunk_while(
      ranges,
      first_range,
      fn r2, r1 ->
        if Range.disjoint?(r1, r2),
          do: {:cont, r1, r2},
          else: {:cont, r1.first..max(r1.last, r2.last)//1}
      end,
      fn final_range -> {:cont, final_range, nil} end
    )
  end

  defp parse_and_consolidate_ranges(str) do
    str
    |> String.split()
    |> Enum.map(fn line ->
      [first, last] = String.split(line, "-")
      String.to_integer(first)..String.to_integer(last)//1
    end)
    |> consolidate()
  end

  defp parse_ids(str), do: Enum.map(String.split(str), &String.to_integer/1)

  # About 3x faster than `n in range` because that logic is generalized for ranges with any step
  defp in_range_fast?(first..last//1, n), do: n >= first and n <= last
end
