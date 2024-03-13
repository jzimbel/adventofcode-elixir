defmodule AdventOfCode.Solution.Year2023.Day13Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2023.Day13

  setup do
    [
      input: """
      #.##..##.
      ..#.##.#.
      ##......#
      ##......#
      ..#.##.#.
      ..##..##.
      #.#.##.#.

      #...##..#
      #....#..#
      ..##..###
      #####.##.
      #####.##.
      ..##..###
      #....#..#
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result == 405
  end

  test "part2", %{input: input} do
    result = input |> parse() |> part2()

    assert result == 400
  end
end
