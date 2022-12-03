defmodule AdventOfCode.Solution.Year2022.Day03Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2022.Day03

  setup do
    [
      input: """
      vJrwpWtwJgWrhcsFMMfFFhFp
      jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
      PmmdzqPrVvPwwTWBwg
      wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
      ttgJtRGJQctTZtZT
      CrZsJsPPZsGzwwsLwLmpwMDw
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 157
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 70
  end
end
