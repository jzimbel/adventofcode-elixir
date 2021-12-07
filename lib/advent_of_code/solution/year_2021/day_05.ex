defmodule AdventOfCode.Solution.Year2021.Day05 do
  defguard is_flat(coords)
           when elem(elem(coords, 0), 0) == elem(elem(coords, 1), 0) or
                  elem(elem(coords, 0), 1) == elem(elem(coords, 1), 1)

  def part1(input) do
    input
    |> parse_lines()
    |> Enum.filter(&is_flat/1)
    |> Enum.reduce(%{}, &draw_line/2)
    |> Enum.count(fn {_, vent_count} -> vent_count >= 2 end)
  end

  def part2(input) do
    input
    |> parse_lines()
    |> Enum.reduce(%{}, &draw_line/2)
    |> Enum.count(fn {_, vent_count} -> vent_count >= 2 end)
  end

  defp draw_line(coords, plane) when is_flat(coords) do
    draw_flat_line(coords, plane)
  end

  defp draw_line({{x1, y1}, {x2, y2}}, plane) do
    Enum.zip(x1..x2, y1..y2)
    |> Enum.reduce(plane, fn coord, p -> Map.update(p, coord, 1, &(&1 + 1)) end)
  end

  defp draw_flat_line({{x, y1}, {x, y2}}, plane) do
    y1..y2
    |> Enum.map(&{x, &1})
    |> Enum.reduce(plane, fn coord, p -> Map.update(p, coord, 1, &(&1 + 1)) end)
  end

  defp draw_flat_line({{x1, y}, {x2, y}}, plane) do
    x1..x2
    |> Enum.map(&{&1, y})
    |> Enum.reduce(plane, fn coord, p -> Map.update(p, coord, 1, &(&1 + 1)) end)
  end

  defp parse_lines(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    ~r|(\d+),(\d+) -> (\d+),(\d+)|
    |> Regex.run(line, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
    |> then(fn [x1, y1, x2, y2] -> {{x1, y1}, {x2, y2}} end)
  end
end
