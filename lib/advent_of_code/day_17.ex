defmodule AdventOfCode.Day17 do
  alias AdventOfCode.CharSpace.{FourDim, ThreeDim}

  def part1(args) do
    sixth_cycle_active_count(args, ThreeDim)
  end

  def part2(args) do
    sixth_cycle_active_count(args, FourDim)
  end

  defp sixth_cycle_active_count(input, mod) do
    input
    |> mod.from_input()
    |> stream_conway()
    |> Enum.at(6)
    |> mod.count_chars(?#)
  end

  defp stream_conway(grid) do
    Stream.iterate(grid, &next_cycle/1)
  end

  defp next_cycle(%mod{} = grid) do
    mod.map(grid, fn
      {coords, ?#} ->
        if count_adjacent_actives(grid, coords) in 2..3, do: ?#, else: ?.

      {coords, ?.} ->
        if count_adjacent_actives(grid, coords) == 3, do: ?#, else: ?.
    end)
  end

  defp count_adjacent_actives(%mod{} = grid, coords) do
    grid
    |> mod.adjacent_values(coords)
    |> Enum.count(&(&1 == ?#))
  end
end
