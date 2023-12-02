defmodule AdventOfCode.Solution.Year2023.Day02Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2023.Day02

  setup do
    [
      input: """
      Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
      Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
      Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
      Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
      Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 8
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 2286
  end
end
