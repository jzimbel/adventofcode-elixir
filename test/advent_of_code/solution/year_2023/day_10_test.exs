defmodule AdventOfCode.Solution.Year2023.Day10Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2023.Day10

  setup do
    [
      input: """
      7-F7-
      .FJ|7
      SJLL7
      |F--J
      LJ.LJ
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result
  end

  @tag :skip
  test "part2", %{input: input} do
    result = part2(input)

    assert result
  end
end
