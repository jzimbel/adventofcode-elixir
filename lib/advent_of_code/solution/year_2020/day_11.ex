defmodule AdventOfCode.Solution.Year2020.Day11 do
  alias AdventOfCode.Grid

  def part1(args) do
    count_occupied(args, fn grid -> grid_mapper(grid, &Grid.adjacent_values/2, 4) end)
  end

  def part2(args) do
    count_occupied(args, fn grid -> grid_mapper(grid, &Grid.queen_move_values/2, 5) end)
  end

  defp count_occupied(input, map_func_generator) do
    input
    |> Grid.from_input()
    |> run_until_stable(map_func_generator)
    |> Grid.count_values(?#)
  end

  defp run_until_stable(grid, map_func_generator) do
    run_until_stable(grid, nil, map_func_generator)
  end

  defp run_until_stable(grid, grid, _), do: grid

  defp run_until_stable(grid, _, map_func_generator) do
    grid
    |> Grid.map(map_func_generator.(grid))
    |> run_until_stable(grid, map_func_generator)
  end

  defp grid_mapper(grid, adjacent_finder, occupied_tolerance) do
    fn
      {coords, ?L} ->
        grid
        |> adjacent_finder.(coords)
        |> Enum.any?(&(&1 == ?#))
        |> if(do: ?L, else: ?#)

      {coords, ?#} ->
        grid
        |> adjacent_finder.(coords)
        |> Enum.count(&(&1 == ?#))
        |> Kernel.<(occupied_tolerance)
        |> if(do: ?#, else: ?L)

      {_, char} ->
        char
    end
  end
end
