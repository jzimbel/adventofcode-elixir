defmodule AdventOfCode.Day17 do
  alias AdventOfCode.{CharHyperspace, CharSpace}

  def part1(args) do
    args
    |> CharSpace.from_input()
    |> stream_conway()
    |> Enum.at(6)
    |> CharSpace.count_chars(?#)
  end

  def part2(args) do
    args
    |> CharHyperspace.from_input()
    |> stream_conway()
    |> Enum.at(6)
    |> CharHyperspace.count_chars(?#)
  end

  defp stream_conway(grid) do
    Stream.iterate(grid, &next_cycle/1)
  end

  defp next_cycle(%grid_module{} = grid) do
    grid_module.map(grid, fn
      {coords, ?#} ->
        if count_adjacent_actives(grid, coords) in 2..3, do: ?#, else: ?.

      {coords, ?.} ->
        if count_adjacent_actives(grid, coords) == 3, do: ?#, else: ?.
    end)
  end

  defp count_adjacent_actives(%grid_module{} = grid, coords) do
    grid
    |> grid_module.adjacent_values(coords)
    |> Enum.count(&(&1 == ?#))
  end
end
