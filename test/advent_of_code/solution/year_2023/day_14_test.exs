defmodule AdventOfCode.Solution.Year2023.Day14Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2023.Day14

  setup do
    [
      input: """
      O....#....
      O.OO#....#
      .....##...
      OO.#O....O
      .O.....O#.
      O.#..O.#.#
      ..O..#O..O
      .......O..
      #....###..
      #OO..#....
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 136
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 64
  end
end
