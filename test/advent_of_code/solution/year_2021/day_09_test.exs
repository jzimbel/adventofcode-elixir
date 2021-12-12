defmodule AdventOfCode.Solution.Year2021.Day09Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day09

  setup do
    [
      input: """
      2199943210
      3987894921
      9856789892
      8767896789
      9899965678
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 15
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 1134
  end
end
