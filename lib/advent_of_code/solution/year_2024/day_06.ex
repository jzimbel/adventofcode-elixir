defmodule AdventOfCode.Solution.Year2024.Day06 do
  use AdventOfCode.Solution.SharedParse

  alias AdventOfCode.Grid, as: G

  @impl true
  def parse(input) do
    grid = G.from_input(input)
    {guard_start, ?^} = G.find_cell(grid, &match?({_, ?^}, &1))

    # Replace ^ with .
    grid = G.replace(grid, guard_start, ?.)

    {grid, guard_start}
  end

  def part1({grid, guard_start}) do
    grid
    |> stream_steps(guard_start)
    |> MapSet.new(fn {coords, _heading} -> coords end)
    |> MapSet.size()
  end

  def part2({grid, guard_start}) do
    path = grid |> stream_steps(guard_start) |> Enum.to_list()

    # Try placing walls along the guard's original path, one at a time
    path
    |> Stream.with_index(fn {coords, _heading}, i -> {coords, i} end)
    # If the path crosses over itself, we don't need to try placing a wall there again
    |> Stream.uniq_by(fn {coords, _i} -> coords end)
    # Can't place a wall on top of the guard
    |> Stream.drop(1)
    |> Enum.count(fn {coords, i} ->
      wall_causes_loop?(grid, coords, i, path)
    end)
  end

  defp wall_causes_loop?(grid, wall_coords, wall_step_idx, path) do
    # Place the wall
    grid = G.replace(grid, wall_coords, ?#)

    # Fast-forward to the step just before the new wall
    step_before_wall = Enum.at(path, wall_step_idx - 1)
    {coords, heading} = step_before_wall
    visited_before_wall = MapSet.new(Enum.take(path, max(0, wall_step_idx - 2)))

    # See if the guard repeats a step from there
    grid
    |> stream_steps(coords, heading)
    |> Enum.reduce_while(visited_before_wall, fn step, visited ->
      if step in visited do
        {:halt, :loop}
      else
        {:cont, MapSet.put(visited, step)}
      end
    end)
    |> Kernel.==(:loop)
  end

  @spec stream_steps(G.t(), G.coordinates()) :: Enumerable.t({G.coordinates(), G.heading()})
  @spec stream_steps(G.t(), G.coordinates(), G.heading()) ::
          Enumerable.t({G.coordinates(), G.heading()})
  defp stream_steps(grid, coords, heading \\ {0, -1}) do
    Stream.unfold({coords, heading}, fn
      nil ->
        nil

      {coords, heading} ->
        next_coords = G.sum_coordinates(coords, heading)

        case G.at(grid, next_coords) do
          ?. -> {{coords, heading}, {next_coords, heading}}
          ?# -> {{coords, heading}, {coords, turn_right(heading)}}
          nil -> {{coords, heading}, nil}
        end
    end)
  end

  defp turn_right({x, y}), do: {-y, x}
end
