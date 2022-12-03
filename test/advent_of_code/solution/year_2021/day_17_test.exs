defmodule AdventOfCode.Solution.Year2021.Day17Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day17

  setup do
    [
      input: """
      target area: x=20..30, y=-10..-5
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 45
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 112
  end
end
