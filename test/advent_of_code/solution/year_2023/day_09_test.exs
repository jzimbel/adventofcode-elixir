defmodule AdventOfCode.Solution.Year2023.Day09Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2023.Day09

  setup do
    [
      input: """
      0 3 6 9 12 15
      1 3 6 10 15 21
      10 13 16 21 30 45
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 114
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 2
  end
end
