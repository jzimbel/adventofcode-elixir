defmodule AdventOfCode.Solution.Year2024.Day14 do
  alias AdventOfCode.Grid, as: G

  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input) do
    pat = ~r/p=(\d+),(\d+) v=(-?\d+),(-?\d+)/

    robots =
      for line <- String.split(input, "\n", trim: true) do
        ns = for n <- Regex.run(pat, line, capture: :all_but_first), do: String.to_integer(n)
        [x, y, vx, vy] = ns
        %{p: {x, y}, v: {vx, vy}}
      end

    %{p: {xmax, _y}} = Enum.max_by(robots, fn %{p: {x, _y}} -> x end)
    %{p: {_x, ymax}} = Enum.max_by(robots, fn %{p: {_x, y}} -> y end)
    {robots, xmax + 1, ymax + 1}
  end

  def part1({robots, width, height}) do
    robots
    |> stream_ticks(width, height)
    |> Enum.at(100)
    |> safety_factor(center(width, height))
  end

  def part2({robots, width, height}) do
    # The tree is a cluster of of 229 #'s, but no other state has clusters
    # anywhere near that size. 50 is fine.
    min_largest_cluster_size = 50

    robots
    |> stream_grids(width, height)
    |> Stream.with_index()
    |> Enum.find(fn {grid, _i} -> largest_cluster_size(grid) >= min_largest_cluster_size end)
  end

  defp stream_ticks(robots, width, height) do
    Stream.iterate(robots, &for(r <- &1, do: tick(r, width, height)))
  end

  defp stream_grids(robots, width, height) do
    robots
    |> stream_ticks(width, height)
    |> Stream.map(&to_grid(&1, width, height))
  end

  defp tick(%{p: {x, y}, v: {vx, vy}} = r, width, height) do
    %{r | p: {Integer.mod(x + vx, width), Integer.mod(y + vy, height)}}
  end

  defp safety_factor(robots, {cx, cy}) do
    robots
    |> Enum.map(& &1.p)
    |> Enum.reject(fn {x, y} -> x == cx or y == cy end)
    |> Enum.group_by(fn {x, y} -> {x > cx, y > cy} end)
    |> Enum.map(fn {_quad, rs} -> length(rs) end)
    # At least for my input, there is never a state where a quadrant is empty.
    # So no need to handle such a case when computing the product.
    |> Enum.product()
  end

  defp center(width, height) do
    # The grid always has odd sidelengths.
    {div(width, 2), div(height, 2)}
  end

  defp to_grid(robots, width, height) do
    se_corner = {width - 1, height - 1}
    rs = Enum.map(robots, &{&1.p, ?#})
    rs = if List.keymember?(rs, {0, 0}, 0), do: rs, else: [{{0, 0}, ?.} | rs]
    rs = if List.keymember?(rs, se_corner, 0), do: rs, else: [{se_corner, ?.} | rs]

    G.from_cells(rs, fn -> ?. end)
  end

  defp largest_cluster_size(grid) do
    (for {coords, ?#} <- grid, reduce: %{max: 0, visited: MapSet.new()} do
       acc ->
         if coords in acc.visited do
           acc
         else
           c = cluster(coords, grid)
           %{acc | max: max(acc.max, MapSet.size(c)), visited: MapSet.union(acc.visited, c)}
         end
     end).max
  end

  defp cluster(coords, grid), do: cluster([coords], grid, MapSet.new())

  defp cluster([], _, c), do: c

  defp cluster(fringe, grid, c) do
    next_fringe =
      for coords <- fringe,
          {next_coords, ?#} <- G.adjacent_cells(grid, coords, :cardinal),
          next_coords not in fringe,
          next_coords not in c,
          uniq: true,
          do: next_coords

    cluster(next_fringe, grid, MapSet.union(c, MapSet.new(fringe)))
  end
end
