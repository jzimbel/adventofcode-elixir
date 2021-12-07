defmodule AdventOfCode.Solution.Year2021.Day02Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day02

  setup do
    [
      input: """
      forward 5
      down 5
      forward 8
      up 3
      down 8
      forward 2
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 150
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 900
  end
end
