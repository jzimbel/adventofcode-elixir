defmodule AdventOfCode.Solution.Year2020.Day10Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2020.Day10

  setup_all do
    [
      input1: """
      16
      10
      15
      5
      1
      11
      7
      19
      6
      12
      4
      """,
      input2: """
      28
      33
      18
      42
      31
      14
      46
      20
      48
      47
      24
      23
      49
      45
      19
      38
      39
      11
      1
      32
      25
      35
      8
      17
      7
      9
      4
      2
      34
      10
      3
      """
    ]
  end

  test "part1", %{input1: input1, input2: input2} do
    result1 = part1(input1)
    assert result1 == 7 * 5

    result2 = part1(input2)
    assert result2 == 22 * 10
  end

  test "part2", %{input1: input1, input2: input2} do
    result1 = part2(input1)
    assert result1 == 8

    result2 = part2(input2)
    assert result2 == 19208
  end
end
