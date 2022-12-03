defmodule AdventOfCode.Solution.Year2021.Day14Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day14

  setup do
    [
      input: """
      NNCB

      CH -> B
      HH -> N
      CB -> H
      NH -> C
      HB -> C
      HC -> B
      HN -> C
      NN -> C
      BH -> H
      NC -> B
      NB -> B
      BN -> B
      BB -> N
      BC -> B
      CC -> N
      CN -> C
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 1588
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 2_188_189_693_529
  end
end
