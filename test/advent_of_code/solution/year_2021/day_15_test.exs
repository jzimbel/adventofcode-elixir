defmodule AdventOfCode.Solution.Year2021.Day15Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day15

  setup do
    [
      input: """
      1163751742
      1381373672
      2136511328
      3694931569
      7463417111
      1319128137
      1359912421
      3125421639
      1293138521
      2311944581
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 40
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 315
  end
end
