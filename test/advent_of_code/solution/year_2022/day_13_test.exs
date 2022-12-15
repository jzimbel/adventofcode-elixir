defmodule AdventOfCode.Solution.Year2022.Day13Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2022.Day13

  setup do
    [
      input: """
      [1,1,3,1,1]
      [1,1,5,1,1]

      [[1],[2,3,4]]
      [[1],4]

      [9]
      [[8,7,6]]

      [[4,4],4,4]
      [[4,4],4,4,4]

      [7,7,7,7]
      [7,7,7]

      []
      [3]

      [[[]]]
      [[]]

      [1,[2,[3,[4,[5,6,7]]]],8,9]
      [1,[2,[3,[4,[5,6,0]]]],8,9]
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 13
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 140
  end
end
