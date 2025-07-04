defmodule AdventOfCode.Solution.Year2024.Day12 do
  use AdventOfCode.Solution.SharedParse

  alias AdventOfCode.Grid, as: G

  @impl true
  def parse(input) do
    grid = G.from_input(input)
    {grid, regions(grid)}
  end

  def part1({grid, rs}) do
    rs
    |> Enum.map(&price_p1(&1, grid))
    |> Enum.sum()
  end

  def part2({grid, rs}) do
    rs
    |> Enum.map(&price_p2(&1, grid))
    |> Enum.sum()
  end

  defp regions(grid) do
    Enum.reduce(grid, %{regions: [], visited: MapSet.new()}, fn {coords, char}, acc ->
      if coords in acc.visited do
        acc
      else
        r = region(coords, char, grid)
        %{acc | regions: [r | acc.regions], visited: MapSet.union(acc.visited, r)}
      end
    end).regions
  end

  defp region(coords, char, grid) do
    region([coords], char, grid, MapSet.new())
  end

  defp region([], _, _, r), do: r

  defp region(fringe, char, grid, r) do
    next_fringe =
      for coords <- fringe,
          {next_coords, ^char} <- G.adjacent_cells(grid, coords, :cardinal),
          next_coords not in fringe,
          next_coords not in r,
          uniq: true,
          do: next_coords

    region(next_fringe, char, grid, MapSet.union(r, MapSet.new(fringe)))
  end

  defp price_p1(r, grid), do: MapSet.size(r) * perimeter(r, grid)
  defp price_p2(r, grid), do: MapSet.size(r) * side_count(r, grid)

  defp perimeter(r, grid) do
    r
    |> Enum.map(fn coords ->
      Enum.count(G.adjacent_coords(grid, coords, :cardinal, false), &(&1 not in r))
    end)
    |> Enum.sum()
  end

  defp side_count(r, grid) do
    r
    # Get a list of {inside_coords, outside_coords} for each fence on the perimeter.
    |> Enum.flat_map(fn coords ->
      grid
      |> G.adjacent_coords(coords, :cardinal, false)
      |> Enum.reject(&(&1 in r))
      |> Enum.map(&{coords, subtract(&1, coords)})
    end)
    |> Enum.group_by(
      # Group fences by the direction they face and the column or row they occupy.
      # Column if facing right/left, row if facing up/down.
      # E.g. a fence on the right side of a square, faces right.
      fn
        {{x, _y}, {_, 0} = heading} -> {heading, x}
        {{_x, y}, {0, _} = heading} -> {heading, y}
      end,
      # Under each {heading, column} group of fences, list the y coordinates.
      # Under each {heading, row} group of fences, list the x coordinates.
      fn
        {{_x, y}, {_, 0}} -> y
        {{x, _y}, {0, _}} -> x
      end
    )
    # Within each column/row, group contiguous sequences of fences.
    # Each group is a side of the region.
    |> Enum.flat_map(fn {_, col_or_row} -> chunk_contiguous(col_or_row) end)
    |> length()
  end

  defp chunk_contiguous(ns) do
    [n1 | ns] = Enum.sort(ns)
    Enum.chunk_while(ns, [n1], &chunker/2, &chunker/1)
  end

  defp chunker(n, chunk) when abs(n - hd(chunk)) == 1, do: {:cont, [n | chunk]}
  defp chunker(n, chunk), do: {:cont, Enum.reverse(chunk), [n]}
  defp chunker(chunk), do: {:cont, Enum.reverse(chunk), nil}

  defp subtract({x1, y1}, {x2, y2}), do: {x1 - x2, y1 - y2}
end
