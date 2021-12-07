defmodule AdventOfCode.Solution.Year2020.Day08Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2020.Day08

  setup_all do
    [
      input: """
      nop +0
      acc +1
      jmp +4
      acc +3
      jmp -3
      acc -99
      acc +1
      jmp -4
      acc +6
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 5
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 8
  end
end
