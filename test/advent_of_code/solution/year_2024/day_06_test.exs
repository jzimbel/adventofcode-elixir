defmodule AdventOfCode.Solution.Year2024.Day06Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day06

  setup do
    [
      input: """
      ....#.....
      .........#
      ..........
      ..#.......
      .......#..
      ..........
      .#..^.....
      ........#.
      #.........
      ......#...
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result
  end

  test "part2", %{input: input} do
    result = input |> parse() |> part2()

    assert result == 6
  end
end
