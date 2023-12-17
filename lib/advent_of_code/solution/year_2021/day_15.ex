defmodule AdventOfCode.Solution.Year2021.Day15 do
  alias AdventOfCode.Grid
  alias Graph

  def part1(input) do
    input
    |> Grid.from_input()
    |> make_numeric()
    |> shortest_path_weight()
  end

  def part2(input) do
    input
    |> Grid.from_input()
    |> make_numeric()
    |> embiggen()
    |> shortest_path_weight()
  end

  defp shortest_path_weight(grid) do
    grid
    |> build_graph()
    |> Graph.dijkstra({0, 0}, {grid.width - 1, grid.height - 1})
    |> Enum.drop(1)
    |> Enum.map(&Grid.at(grid, &1))
    |> Enum.sum()
  end

  defp build_graph(grid) do
    Graph.new()
    |> Graph.add_edges(
      Stream.flat_map(grid.grid, fn {coords, _} ->
        grid
        |> Grid.adjacent_cells(coords, :cardinal)
        |> Enum.map(fn {neighbor_coords, neighbor_value} ->
          {coords, neighbor_coords, weight: neighbor_value}
        end)
      end)
    )
  end

  defp embiggen(grid) do
    grid
    |> Grid.to_list()
    |> Stream.flat_map(fn {{x, y}, value} ->
      for x_offset <- 0..4,
          y_offset <- 0..4 do
        {
          {x + grid.width * x_offset, y + grid.height * y_offset},
          rem(value + x_offset + y_offset - 1, 9) + 1
        }
      end
    end)
    |> then(&%Grid{grid: Enum.into(&1, %{}), width: grid.width * 5, height: grid.height * 5})
  end

  defp make_numeric(grid) do
    Grid.map(grid, fn {_, char_value} -> char_value - ?0 end)
  end
end
