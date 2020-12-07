defmodule AdventOfCode.Day06Test do
  use ExUnit.Case

  import AdventOfCode.Day06

  setup_all do
    [
      input: """
      abc

      a
      b
      c

      ab
      ac

      a
      a
      a
      a

      b
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 11
  end

  @tag :skip
  test "part2", %{input: input} do
    result = part2(input)

    assert result == 6
  end
end
