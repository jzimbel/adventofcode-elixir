defmodule AdventOfCode.Day02Test do
  use ExUnit.Case

  import AdventOfCode.Day02

  setup_all do
    [
      input: """
      1-3 a: abcde
      1-3 b: cdefg
      2-9 c: ccccccccc
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 2
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 1
  end
end
