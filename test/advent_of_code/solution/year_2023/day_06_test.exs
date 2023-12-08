defmodule AdventOfCode.Solution.Year2023.Day06Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2023.Day06

  setup do
    [
      input: """
      Time:      7  15   30
      Distance:  9  40  200
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 288
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 71503
  end
end
