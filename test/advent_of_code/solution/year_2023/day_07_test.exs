defmodule AdventOfCode.Solution.Year2023.Day07Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2023.Day07

  setup do
    [
      input: """
      32T3K 765
      T55J5 684
      KK677 28
      KTJJT 220
      QQQJA 483
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 6440
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 5905
  end
end
