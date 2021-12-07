defmodule AdventOfCode.Solution.Year2020.Day01Test do
  use ExUnit.Case

  import AdventOfCode.Solution.Year2020.Day01

  setup_all do
    [
      input: """
      1721
      979
      366
      299
      675
      1456
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 514_579
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 241_861_950
  end
end
