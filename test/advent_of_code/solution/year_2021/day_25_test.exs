defmodule AdventOfCode.Solution.Year2021.Day25Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day25

  setup do
    [
      input: """
      v...>>.vv>
      .vv>>.vv..
      >>.>v>...v
      >>v>>.>.v.
      v>v.vv.v..
      >.>>..v...
      .vv..>.>v.
      v.v..>>v.v
      ....v..v.>
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 58
  end

  @tag :skip
  test "part2", %{input: input} do
    result = part2(input)

    assert result
  end
end
