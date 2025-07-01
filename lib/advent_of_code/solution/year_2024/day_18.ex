defmodule AdventOfCode.Solution.Year2024.Day18 do
  alias AdventOfCode.Algo
  alias AdventOfCode.Grid, as: G

  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input, grid_size \\ 71) do
    grid = G.new(grid_size, grid_size)

    drops =
      for line <- String.split(input, "\n", trim: true) do
        [x, y] = for n <- String.split(line, ","), do: String.to_integer(n)
        {x, y}
      end

    {grid, drops}
  end

  def part1({grid, drops}, t \\ 1024) do
    grid =
      drops
      |> Stream.take(t)
      |> Enum.reduce(grid, &G.replace(&2, &1, ?#))

    goal = {grid.width - 1, grid.height - 1}

    {_path, cost} =
      grid
      |> Algo.a_star(start_state(goal), goal)
      |> Enum.fetch!(0)

    cost
  end

  def part2({grid, drops}) do
    with {:ok, path} <- find_path(grid),
         {x, y} when is_integer(x) and is_integer(y) <-
           Enum.reduce_while(drops, {grid, path}, &check_drop/2) do
      "#{x},#{y}"
    else
      _initial_path_blocked_or_path_never_blocked -> nil
    end
  end

  defp start_state(goal) do
    %AdventOfCode.Algo.AStar.State{
      current: {0, 0},
      heuristic: AdventOfCode.Algo.Helpers.manhattan_distance({0, 0}, goal)
    }
  end

  defp check_drop(drop, {grid, prev_path}) do
    grid = G.replace(grid, drop, ?#)

    case find_path(grid, prev_path, drop) do
      {:ok, path} -> {:cont, {grid, path}}
      :error -> {:halt, drop}
    end
  end

  defp find_path(grid, prev_path \\ nil, drop \\ nil)

  defp find_path(grid, nil, _drop) do
    goal = {grid.width - 1, grid.height - 1}

    grid
    |> Algo.a_star(start_state(goal), goal)
    |> Stream.map(fn {path, _cost} -> path end)
    |> Enum.fetch(0)
  end

  defp find_path(grid, prev_path, drop) do
    if drop in prev_path do
      find_path(grid)
    else
      {:ok, prev_path}
    end
  end
end
