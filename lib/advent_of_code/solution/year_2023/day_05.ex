defmodule AdventOfCode.Solution.Year2023.Day05 do
  def part1(input), do: solve(input, &parse_seed_ranges_p1/1)
  def part2(input), do: solve(input, &parse_seed_ranges_p2/1)

  defp solve(input, seed_ranges_parser) do
    {seed_ranges, transforms} = parse(input, seed_ranges_parser)

    seed_ranges
    |> Task.async_stream(
      fn seed_range ->
        seed_range
        |> seed_range_to_location_ranges(transforms)
        |> Stream.map(& &1.first)
        |> Enum.min()
      end,
      ordered: false
    )
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.min()
  end

  defp parse(input, seed_ranges_parser) do
    [seeds_line | transform_lines] = String.split(input, "\n\n", trim: true)

    {seed_ranges_parser.(seeds_line), Enum.map(transform_lines, &parse_transform/1)}
  end

  defp parse_seed_ranges_p1("seeds: " <> seeds_str) do
    seeds_str
    |> String.split()
    |> Stream.map(&String.to_integer/1)
    |> Stream.map(&(&1..&1//1))
  end

  defp parse_seed_ranges_p2("seeds: " <> seeds_str) do
    seeds_str
    |> String.split()
    |> Stream.map(&String.to_integer/1)
    |> Stream.chunk_every(2)
    |> Stream.map(fn [start, len] -> start..(start + len - 1)//1 end)
  end

  defp parse_transform(transform_lines) do
    transform_lines
    |> String.split("\n", trim: true)
    |> Stream.drop(1)
    |> Stream.map(fn line ->
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(fn [dest_start, src_start, len] ->
      {src_start..(src_start + len - 1)//1, dest_start - src_start}
    end)
  end

  defp seed_range_to_location_ranges(seed_range, transforms) do
    Enum.reduce(transforms, [seed_range], &apply_transform/2)
  end

  defp apply_transform(transform_set, seed_ranges) do
    Enum.reduce_while(transform_set, %{unshifted: seed_ranges, shifted: []}, fn
      _, %{unshifted: []} = acc ->
        {:halt, acc}

      {window, shift_by}, acc ->
        updates =
          acc.unshifted
          |> Enum.reduce(%{unshifted: [], shifted: []}, fn seed_range, acc ->
            cond do
              Range.disjoint?(window, seed_range) ->
                Map.update!(acc, :unshifted, &[seed_range | &1])

              window == seed_range ->
                Map.update!(acc, :shifted, &[Range.shift(seed_range, shift_by) | &1])

              true ->
                {shifted_range, unshifted_ranges} =
                  intersect_and_shift(seed_range, window, shift_by)

                acc
                |> Map.update!(:shifted, &[shifted_range | &1])
                |> Map.update!(:unshifted, &(unshifted_ranges ++ &1))
            end
          end)

        acc
        |> Map.put(:unshifted, updates.unshifted)
        |> Map.update!(:shifted, &(updates.shifted ++ &1))
        |> then(&{:cont, &1})
    end)
    |> then(&(&1.unshifted ++ &1.shifted))
  end

  defp intersect_and_shift(sl..sr//1, tl..tr//1, shift_by) do
    {
      Range.shift(max(sl, tl)..min(sr, tr)//1, shift_by),
      Enum.reject([sl..(tl - 1)//1, (tr + 1)..sr//1], &(Range.size(&1) == 0))
    }
  end
end
