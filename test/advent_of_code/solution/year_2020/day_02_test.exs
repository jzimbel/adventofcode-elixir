defmodule AdventOfCode.Solution.Year2020.Day02Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2020.Day02

  setup_all do
    [
      input: """
      1-3 a: abcde
      1-3 b: cdefg
      2-9 c: ccccccccc
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 2
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 1
  end
end
