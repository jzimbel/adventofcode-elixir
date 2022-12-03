defmodule AdventOfCode.Solution.Year2022.Day02Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2022.Day02

  setup do
    [
      input: """
      A Y
      B X
      C Z
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 15
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 12
  end
end
