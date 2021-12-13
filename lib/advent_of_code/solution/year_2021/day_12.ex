defmodule AdventOfCode.Solution.Year2021.Day12 do
  def part1(input) do
    input
    |> parse_cave_map()
    |> count_paths(&visitable_p1?/2)
  end

  def part2(input) do
    input
    |> parse_cave_map()
    |> count_paths(&visitable_p2?/2)
  end

  defp count_paths(cave \\ :start, visit_counts \\ %{}, cave_map, visitable_fn)

  defp count_paths(:end, _, _, _), do: 1

  defp count_paths(cave, visit_counts, cave_map, visitable_fn) do
    visit_counts =
      case cave do
        {:small, id} -> Map.update(visit_counts, id, 1, &(&1 + 1))
        _ -> visit_counts
      end

    cave_map[cave]
    |> Enum.filter(&visitable_fn.(&1, visit_counts))
    |> Enum.map(&count_paths(&1, visit_counts, cave_map, visitable_fn))
    |> Enum.sum()
  end

  # Part 1 visitable checker
  defp visitable_p1?(:start, _visit_counts), do: false

  defp visitable_p1?({:small, id}, visit_counts) do
    Map.get(visit_counts, id, 0) == 0
  end

  defp visitable_p1?(_cave, _visit_counts), do: true

  # Part 2 visitable checker
  defp visitable_p2?(:start, _visit_counts), do: false

  defp visitable_p2?({:small, id}, visit_counts) do
    case Map.get(visit_counts, id, 0) do
      0 -> true
      1 -> Enum.all?(visit_counts, fn {_, visit_count} -> visit_count < 2 end)
      _ -> false
    end
  end

  defp visitable_p2?(_cave, _visit_counts), do: true

  defp parse_cave_map(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Regex.run(~r/(\w+)-(\w+)/, &1, capture: :all_but_first))
    |> Enum.map(fn entries -> Enum.map(entries, &parse_cave/1) end)
    |> Enum.reduce(%{}, fn [cave1, cave2], cave_map ->
      cave_map
      |> Map.update(cave1, [cave2], fn reachable -> [cave2 | reachable] end)
      |> Map.update(cave2, [cave1], fn reachable -> [cave1 | reachable] end)
    end)
  end

  defp parse_cave("start"), do: :start
  defp parse_cave("end"), do: :end

  defp parse_cave(<<first_char, _rest::binary>> = cave) when first_char in ?a..?z do
    {:small, String.to_atom(cave)}
  end

  defp parse_cave(cave), do: {:large, String.to_atom(cave)}
end
