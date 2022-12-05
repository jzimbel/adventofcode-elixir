defmodule AdventOfCode.Solution.Year2022.Day05Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2022.Day05

  setup do
    [
      input: """
          [D]
      [N] [C]
      [Z] [M] [P]
       1   2   3

      move 1 from 2 to 1
      move 3 from 1 to 3
      move 2 from 2 to 1
      move 1 from 1 to 2
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == "CMZ"
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == "MCD"
  end
end
