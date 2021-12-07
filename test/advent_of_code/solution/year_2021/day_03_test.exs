defmodule AdventOfCode.Solution.Year2021.Day03Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day03

  setup do
    [
      input: """
      00100
      11110
      10110
      10111
      10101
      01111
      00111
      11100
      10000
      11001
      00010
      01010
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 198
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 230
  end
end
