defmodule AdventOfCode.Solution.Year2021.Day18Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day18

  setup do
    [
      input: """
      [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
      [[[5,[2,8]],4],[5,[[9,9],0]]]
      [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
      [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
      [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
      [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
      [[[[5,4],[7,7]],8],[[8,3],8]]
      [[9,3],[[9,9],[6,[4,9]]]]
      [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
      [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 4140
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 3993
  end
end
