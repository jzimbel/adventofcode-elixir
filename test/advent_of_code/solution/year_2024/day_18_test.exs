defmodule AdventOfCode.Solution.Year2024.Day18Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day18

  setup do
    [
      input: """
      5,4
      4,2
      4,5
      3,0
      2,1
      6,3
      2,4
      1,5
      0,6
      3,3
      2,6
      5,1
      1,2
      5,5
      2,5
      6,5
      1,4
      0,4
      6,4
      1,1
      6,1
      1,0
      0,5
      1,6
      2,0
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse(7) |> part1(12)

    assert result == 22
  end

  test "part2", %{input: input} do
    result = input |> parse(7) |> part2()

    assert result == "6,1"
  end
end
