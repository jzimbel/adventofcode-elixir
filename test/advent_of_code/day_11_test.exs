defmodule AdventOfCode.Day11Test do
  use ExUnit.Case

  import AdventOfCode.Day11

  setup_all do
    [
      input: """
      L.LL.LL.LL
      LLLLLLL.LL
      L.L.L..L..
      LLLL.LL.LL
      L.LL.LL.LL
      L.LLLLL.LL
      ..L.L.....
      LLLLLLLLLL
      L.LLLLLL.L
      L.LLLLL.LL
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 37
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 26
  end
end
