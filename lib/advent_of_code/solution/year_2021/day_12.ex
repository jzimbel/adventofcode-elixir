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

  defp count_paths(cave \\ "start", visit_counts \\ %{}, cave_map, visitable_fn)

  defp count_paths("end", _, _, _), do: 1

  defp count_paths(cave, visit_counts, cave_map, visitable_fn) do
    visit_counts = Map.update(visit_counts, cave, 1, &(&1 + 1))

    cave_map[cave]
    |> Enum.filter(&visitable_fn.(&1, visit_counts))
    |> Enum.map(&count_paths(&1, visit_counts, cave_map, visitable_fn))
    |> Enum.sum()
  end

  # Part 1 visitable checker
  defp visitable_p1?(<<first_char, _rest::binary>> = small_cave, visit_counts)
       when first_char in ?a..?z do
    Map.get(visit_counts, small_cave, 0) == 0
  end

  defp visitable_p1?(_cave, _visit_counts), do: true

  # Part 2 visitable checker
  defp visitable_p2?(terminus, visit_counts) when terminus in ~w[start end] do
    Map.get(visit_counts, terminus, 0) == 0
  end

  defp visitable_p2?(<<first_char, _rest::binary>> = small_cave, visit_counts)
       when first_char in ?a..?z do
    case Map.get(visit_counts, small_cave, 0) do
      0 -> true
      1 -> no_small_caves_visited_twice?(visit_counts)
      _ -> false
    end
  end

  defp visitable_p2?(_cave, _visit_counts), do: true

  defp no_small_caves_visited_twice?(visit_counts) do
    visit_counts
    |> Enum.filter(fn {cave, _} -> small_cave?(cave) end)
    |> Enum.all?(fn {_, visit_count} -> visit_count < 2 end)
  end

  defp small_cave?(<<first_char, _rest::binary>>), do: first_char in ?a..?z

  defp parse_cave_map(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Regex.run(~r/(\w+)-(\w+)/, &1, capture: :all_but_first))
    |> Enum.reduce(%{}, fn [cave1, cave2], cave_map ->
      cave_map
      |> Map.update(cave1, [cave2], fn reachable -> [cave2 | reachable] end)
      |> Map.update(cave2, [cave1], fn reachable -> [cave1 | reachable] end)
    end)
  end
end
