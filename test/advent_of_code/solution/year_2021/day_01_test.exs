defmodule AdventOfCode.Solution.Year2021.Day01Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day01

  setup do
    [
      input: """
      199
      200
      208
      210
      200
      207
      240
      269
      260
      263
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 7
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 5
  end
end
