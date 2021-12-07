defmodule AdventOfCode.Solution.Year2021.Day05Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day05

  setup do
    [
      input: """
      0,9 -> 5,9
      8,0 -> 0,8
      9,4 -> 3,4
      2,2 -> 2,1
      7,0 -> 7,4
      6,4 -> 2,0
      0,9 -> 2,9
      3,4 -> 1,4
      0,0 -> 8,8
      5,5 -> 8,2
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 5
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 12
  end
end
