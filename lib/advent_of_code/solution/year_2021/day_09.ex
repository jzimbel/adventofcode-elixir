defmodule AdventOfCode.Solution.Year2021.Day09 do
  alias AdventOfCode.Grid

  def part1(input) do
    input
    |> Grid.from_input()
    |> local_minima_risk_levels()
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> Grid.from_input()
    |> get_basins()
    |> Enum.map(&MapSet.size/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  defp local_minima_risk_levels(grid) do
    grid
    |> Grid.filter_cells(fn {coords, value} ->
      grid
      |> Grid.adjacent_values(coords)
      |> Enum.all?(&(value < &1))
    end)
    # codepoint for '0' (aka ?0 in Elixir syntax) == 48;
    # The problem calls for value + 1, so subtract 47 from codepoint
    |> Enum.map(fn {_coords, char} -> char - 47 end)
  end

  defp get_basins(grid) do
    grid
    |> Grid.to_list()
    |> non_nine_coords()
    |> Enum.map(fn coords ->
      adjacent_non_nines =
        grid
        |> Grid.adjacent_cells(coords, :cardinal)
        |> non_nine_coords()

      MapSet.new([coords | adjacent_non_nines])
    end)
    |> merge_basins()
  end

  defp non_nine_coords(cells) do
    Enum.flat_map(cells, fn
      {_coords, ?9} -> []
      {coords, _value} -> [coords]
    end)
  end

  defp merge_basins(seed_basins, merged_basins \\ [])

  defp merge_basins([], merged_basins), do: merged_basins

  defp merge_basins([seed_basin | seed_basins], merged_basins) do
    {remaining, merged_basin} = flood_basin(seed_basin, seed_basins)

    merge_basins(remaining, [merged_basin | merged_basins])
  end

  defp flood_basin(basin, seed_basins) do
    import MapSet, only: [intersection: 2, size: 1, union: 2]

    {remaining_seed_basins, new_basin} =
      Enum.flat_map_reduce(seed_basins, basin, fn seed_basin, acc ->
        if size(intersection(acc, seed_basin)) > 0 do
          {[], union(acc, seed_basin)}
        else
          {[seed_basin], acc}
        end
      end)

    if size(basin) == size(new_basin) do
      {remaining_seed_basins, new_basin}
    else
      flood_basin(new_basin, remaining_seed_basins)
    end
  end
end
