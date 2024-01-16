defmodule AdventOfCode.Solution.Year2023.Day22Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2023.Day22

  setup do
    [
      input: """
      1,0,1~1,2,1
      0,0,2~2,0,2
      0,2,3~2,2,3
      0,0,4~0,2,4
      2,0,5~2,2,5
      0,1,6~2,1,6
      1,1,8~1,1,9
      """,
      edge_case: """
      1,0,1~1,2,1
      0,0,2~2,0,2
      0,2,3~2,2,3
      0,0,4~0,2,4
      2,0,5~2,2,5
      0,1,6~2,1,6
      1,1,8~1,1,9
      1,1,10~1,3,10
      1,2,11~1,4,11
      """
    ]
  end

  test "part1", %{input: input, edge_case: edge_case} do
    result = part1(input)

    assert result == 5

    result = part1(edge_case)

    assert result == 5
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 7
  end
end
