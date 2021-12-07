defmodule AdventOfCode.Solution.Year2020.Day12Test do
  use ExUnit.Case

  import AdventOfCode.Solution.Year2020.Day12

  setup_all do
    [
      input: """
      F10
      N3
      F7
      R90
      F11
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 25
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 286
  end
end
