defmodule AdventOfCode.Day11 do
  alias AdventOfCode.CharGrid

  def part1(args) do
    count_occupied(args, fn grid -> grid_mapper(grid, &CharGrid.adjacent_values/2, 4) end)
  end

  def part2(args) do
    count_occupied(args, fn grid -> grid_mapper(grid, &CharGrid.queen_move_values/2, 5) end)
  end

  defp count_occupied(input, map_func_generator) do
    input
    |> CharGrid.from_input()
    |> run_until_stable(map_func_generator)
    |> CharGrid.count_chars(?#)
  end

  defp run_until_stable(grid, map_func_generator) do
    run_until_stable(grid, nil, map_func_generator)
  end

  defp run_until_stable(grid, grid, _), do: grid

  defp run_until_stable(grid, _, map_func_generator) do
    grid
    |> CharGrid.map(map_func_generator.(grid))
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
