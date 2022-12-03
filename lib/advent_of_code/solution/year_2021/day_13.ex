defmodule AdventOfCode.Solution.Year2021.Day13 do
  alias AdventOfCode.CharSpace.TwoDim

  def part1(input) do
    input
    |> parse_input()
    |> stream_folds()
    |> Enum.at(1)
    |> MapSet.size()
  end

  def part2(input) do
    input
    |> parse_input()
    |> stream_folds()
    |> Enum.at(-1)
    |> TwoDim.from_coords_list()
    |> to_string()
  end

  defp stream_folds(initial_data) do
    Stream.unfold(initial_data, fn
      nil ->
        nil

      {coords_set, []} ->
        {coords_set, nil}

      {coords_set, [instruction | instructions]} ->
        {coords_set, {fold(coords_set, instruction), instructions}}
    end)
  end

  defp fold(coords_set, {:left, fold_x}) do
    {to_fold, to_remain} =
      coords_set
      |> Enum.reject(fn {x, _} -> x == fold_x end)
      |> Enum.split_with(fn {x, _} -> x > fold_x end)

    to_fold
    |> MapSet.new(fn {x, y} -> {2 * fold_x - x, y} end)
    |> MapSet.union(MapSet.new(to_remain))
  end

  defp fold(coords_set, {:up, fold_y}) do
    {to_fold, to_remain} =
      coords_set
      |> Enum.reject(fn {_, y} -> y == fold_y end)
      |> Enum.split_with(fn {_, y} -> y > fold_y end)

    to_fold
    |> MapSet.new(fn {x, y} -> {x, 2 * fold_y - y} end)
    |> MapSet.union(MapSet.new(to_remain))
  end

  defp parse_input(input) do
    [coords, instructions] = String.split(input, "\n\n", trim: true)

    {parse_coords_set(coords), parse_instructions(instructions)}
  end

  defp parse_coords_set(coords) do
    coords
    |> String.split("\n", trim: true)
    |> MapSet.new(fn line ->
      ~r/(\d+),(\d+)/
      |> Regex.run(line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp parse_instructions(instructions) do
    instructions
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      ~r/(x|y)=(\d+)/
      |> Regex.run(line, capture: :all_but_first)
      |> then(fn
        ["x", n] -> {:left, String.to_integer(n)}
        ["y", n] -> {:up, String.to_integer(n)}
      end)
    end)
  end
end
