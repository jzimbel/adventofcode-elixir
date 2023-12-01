defmodule AdventOfCode.Solution.Year2023.Day01Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2023.Day01

  setup do
    [
      input: """
      1abc2
      pqr3stu8vwx
      a1b2c3d4e5f
      treb7uchet
      """,
      input2: """
      two1nine
      eightwothree
      abcone2threexyz
      xtwone3four
      4nineeightseven2
      zoneight234
      7pqrstsixteen
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 142
  end

  test "part2", %{input2: input} do
    result = part2(input)

    assert result == 281
  end
end
