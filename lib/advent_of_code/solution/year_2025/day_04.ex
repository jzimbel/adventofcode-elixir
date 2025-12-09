defmodule AdventOfCode.Solution.Year2025.Day04 do
  alias AdventOfCode.Grid, as: G

  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input), do: G.from_input(input)

  def part1(grid), do: map_size(forklift_cells(grid))

  def part2(grid) do
    {grid, 0}
    |> Stream.unfold(&remove_forkliftable/1)
    |> Enum.sum()
  end

  defp remove_forkliftable({grid, i}) do
    ## Uncomment to save images of each pass over the grid:
    # File.mkdir_p!(Path.join(File.cwd!(), "output"))
    # {:ok, png} = G.to_png(grid, %{?. => "#FFFFFF", ?@ => "#000000"})
    # path = Path.join([File.cwd!(), "output", "forklifted#{i}.png"])
    # File.write!(path, png)

    case forklift_cells(grid) do
      m when map_size(m) == 0 -> nil
      removals -> {map_size(removals), {G.replace(grid, removals), i + 1}}
    end
  end

  defp forklift_cells(grid) do
    for {coords, ?@} <- grid, forkliftable?(coords, grid), into: %{}, do: {coords, ?.}
  end

  defp forkliftable?(coords, grid) do
    grid
    |> G.adjacent_values(coords)
    |> Enum.count_until(&(&1 == ?@), 4)
    |> Kernel.!=(4)
  end
end
