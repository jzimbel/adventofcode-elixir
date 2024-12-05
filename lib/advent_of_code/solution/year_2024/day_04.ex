defmodule AdventOfCode.Solution.Year2024.Day04 do
  alias AdventOfCode.Grid, as: G

  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input), do: G.from_input(input)

  @spec part1(G.t()) :: integer()
  def part1(grid) do
    grid
    |> G.filter_cells(&match?({_, ?X}, &1))
    |> Enum.map(&count_xmas(&1, grid))
    |> Enum.sum()
  end

  def part2(grid) do
    grid
    |> G.filter_cells(&match?({_, ?A}, &1))
    |> Enum.count(&x_mas?(&1, grid))
  end

  defp count_xmas({coords, ?X}, grid) do
    grid
    |> G.lines_of_values(coords, :all, true)
    |> Enum.count(&match?(~c"MAS", Enum.take(&1, 3)))
  end

  defp x_mas?({coords, ?A}, grid) do
    with [nw, sw, ne, se] <- G.adjacent_values(grid, coords, :intercardinal) do
      case {nw, sw, ne, se} do
        {a, a, b, b} when a != b and a in ~C"MS" and b in ~C"MS" -> true
        {a, b, a, b} when a != b and a in ~C"MS" and b in ~C"MS" -> true
        _ -> false
      end
    else
      _A_is_on_edge_of_grid -> false
    end
  end
end
