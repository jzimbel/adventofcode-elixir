defmodule AdventOfCode.Solution.Year2021.Day25 do
  def part1(input) do
    {grid, width, height} = parse_input(input)

    grid
    |> Stream.iterate(&step(&1, width, height))
    |> Stream.chunk_every(2, 1, :discard)
    |> Stream.with_index(1)
    |> Enum.find(&match?({[grid, grid], _}, &1))
    |> elem(1)
  end

  def part2(_input) do
  end

  defp step(grid, width, height) do
    grid
    |> Enum.into(%{}, fn
      {{x, y}, ?>} = cuke ->
        move_to = {rem(x + 1, width), y}

        case grid[move_to] do
          nil -> {move_to, ?>}
          _ -> cuke
        end

      down ->
        down
    end)
    |> then(fn grid ->
      Enum.into(grid, %{}, fn
        {{x, y}, ?v} = cuke ->
          move_to = {x, rem(y + 1, height)}

          case grid[move_to] do
            nil -> {move_to, ?v}
            _ -> cuke
          end

        right ->
          right
      end)
    end)
  end

  defp parse_input(input) do
    charlists =
      input
      |> String.split()
      |> Enum.map(&String.to_charlist/1)

    height = length(charlists)
    width = length(hd(charlists))

    grid =
      for {line, y} <- Enum.with_index(charlists),
          {char, x} <- Enum.with_index(line),
          char != ?.,
          into: %{},
          do: {{x, y}, char}

    {grid, width, height}
  end
end
