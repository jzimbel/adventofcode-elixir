defmodule AdventOfCode.Solution.Year2021.Day11Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day11

  setup do
    [
      input: """
      5483143223
      2745854711
      5264556173
      6141336146
      6357385478
      4167524645
      2176841721
      6882881134
      4846848554
      5283751526
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 1656
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 195
  end
end
