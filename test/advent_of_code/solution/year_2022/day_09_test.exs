defmodule AdventOfCode.Solution.Year2022.Day09Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2022.Day09

  setup do
    [
      input: """
      R 4
      U 4
      L 3
      D 1
      R 4
      D 1
      L 5
      R 2
      """,
      input2: """
      R 5
      U 8
      L 8
      D 3
      R 17
      D 10
      L 25
      U 20
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 13
  end

  test "part2", %{input: input, input2: input2} do
    result1 = part2(input)
    result2 = part2(input2)

    assert result1 == 1
    assert result2 == 36
  end
end
