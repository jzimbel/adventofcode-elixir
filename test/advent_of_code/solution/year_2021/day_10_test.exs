defmodule AdventOfCode.Solution.Year2021.Day10Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day10

  setup do
    [
      input: """
      [({(<(())[]>[[{[]{<()<>>
      [(()[<>])]({[<{<<[]>>(
      {([(<{}[<>[]}>{[]{[(<()>
      (((({<>}<{<{<>}{[]{[]{}
      [[<[([]))<([[{}[[()]]]
      [{[{({}]{}}([{[{{{}}([]
      {<[[]]>}<{[{[{[]{()[[[]
      [<(<(<(<{}))><([]([]()
      <{([([[(<>()){}]>(<<{{
      <{([{{}}[<[[[<>{}]]]>[]]
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 26397
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 288_957
  end
end
