defmodule AdventOfCode.Solution.Year2022.Day14 do
  @source {500, 0}

  def part1(input) do
    discard_sand = fn coords, _sand -> coords end

    input
    |> stream_states(discard_sand)
    |> Stream.map(&MapSet.size/1)
    |> Stream.chunk_every(2, 1)
    |> Enum.find_index(&match?([count, count], &1))
  end

  def part2(input) do
    place_sand_on_floor = &MapSet.put(&1, &2)

    input
    |> stream_states(place_sand_on_floor)
    |> Enum.find_index(&MapSet.member?(&1, @source))
  end

  defp stream_states(input, floor_fn) do
    {coords, floor_y} = parse(input)
    Stream.iterate(coords, &drop_sand(&1, {floor_y, floor_fn}))
  end

  defp drop_sand(coords, floor, sand \\ @source, move \\ :d)

  defp drop_sand(coords, {floor_y, floor_fn} = floor, {x, y} = sand, :d) do
    next = {x, y + 1}

    cond do
      MapSet.member?(coords, next) -> drop_sand(coords, floor, sand, :l)
      y == floor_y -> floor_fn.(coords, sand)
      true -> drop_sand(coords, floor, next, :d)
    end
  end

  defp drop_sand(coords, floor, {x, y} = sand, :l) do
    next = {x - 1, y + 1}

    if MapSet.member?(coords, next),
      do: drop_sand(coords, floor, sand, :r),
      else: drop_sand(coords, floor, next, :d)
  end

  defp drop_sand(coords, floor, {x, y} = sand, :r) do
    next = {x + 1, y + 1}

    if MapSet.member?(coords, next),
      do: MapSet.put(coords, sand),
      else: drop_sand(coords, floor, next, :d)
  end

  defp parse(input) do
    coords =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_path/1)
      |> Enum.reduce(MapSet.new(), &MapSet.union/2)

    floor_y =
      coords
      |> Enum.max_by(&elem(&1, 1))
      |> elem(1)
      |> Kernel.+(1)

    {coords, floor_y}
  end

  defp parse_path(line) do
    ~r/(\d+),(\d+)/
    |> Regex.scan(line, capture: :all_but_first)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.flat_map(&parse_stroke/1)
    |> MapSet.new()
  end

  defp parse_stroke([[x1, y1], [x2, y2]]) do
    for x <- String.to_integer(x1)..String.to_integer(x2),
        y <- String.to_integer(y1)..String.to_integer(y2),
        do: {x, y}
  end
end
