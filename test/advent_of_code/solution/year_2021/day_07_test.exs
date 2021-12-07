defmodule AdventOfCode.Solution.Year2021.Day07Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day07

  setup do
    [
      input: """
      16,1,2,0,4,2,7,1,2,14
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 37
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 168
  end
end
