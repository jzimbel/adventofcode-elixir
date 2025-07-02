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

    {:ok, {_path, cost}} = Algo.a_star_one(grid, {0, 0}, goal)

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

    case Algo.a_star_one(grid, {0, 0}, goal) do
      {:ok, {path, _cost}} -> {:ok, path}
      :error -> :error
    end
  end

  defp find_path(grid, prev_path, drop) do
    if drop in prev_path do
      find_path(grid)
    else
      {:ok, prev_path}
    end
  end
end
