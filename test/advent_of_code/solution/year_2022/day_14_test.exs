defmodule AdventOfCode.Solution.Year2022.Day14Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2022.Day14

  setup do
    [
      input: """
      498,4 -> 498,6 -> 496,6
      503,4 -> 502,4 -> 502,9 -> 494,9
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 24
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 93
  end
end
