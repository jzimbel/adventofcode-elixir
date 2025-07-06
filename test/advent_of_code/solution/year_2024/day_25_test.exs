defmodule AdventOfCode.Solution.Year2024.Day25Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day25

  setup do
    [
      input: """
      #####
      .####
      .####
      .####
      .#.#.
      .#...
      .....

      #####
      ##.##
      .#.##
      ...##
      ...#.
      ...#.
      .....

      .....
      #....
      #....
      #...#
      #.#.#
      #.###
      #####

      .....
      .....
      #.#..
      ###..
      ###.#
      ###.#
      #####

      .....
      .....
      .....
      #....
      #.#..
      #.#.#
      #####
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result == 3
  end

  @tag :skip
  test "part2", %{input: input} do
    result = part2(input)

    assert result
  end
end
