defmodule AdventOfCode.Day14Test do
  use ExUnit.Case

  import AdventOfCode.Day14

  setup_all do
    [
      input: """
      mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
      mem[8] = 11
      mem[7] = 101
      mem[8] = 0
      """,
      input2: """
      mask = 000000000000000000000000000000X1001X
      mem[42] = 100
      mask = 00000000000000000000000000000000X0XX
      mem[26] = 1
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 165
  end

  test "part2", %{input2: input} do
    result = part2(input)

    assert result == 208
  end
end
