defmodule AdventOfCode.Solution.Year2023.Day11Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2023.Day11

  setup do
    [
      input: """
      ...#......
      .......#..
      #.........
      ..........
      ......#...
      .#........
      .........#
      ..........
      .......#..
      #...#.....
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result == 374
  end

  test "part2", %{input: input} do
    result = input |> parse() |> solve(9)

    assert result == 1030
  end
end
