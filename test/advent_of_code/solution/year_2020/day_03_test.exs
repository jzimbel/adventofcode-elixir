defmodule AdventOfCode.Solution.Year2020.Day03Test do
  use ExUnit.Case

  import AdventOfCode.Solution.Year2020.Day03

  setup_all do
    [
      input: """
      ..##.......
      #...#...#..
      .#....#..#.
      ..#.#...#.#
      .#...##..#.
      ..#.##.....
      .#.#.#....#
      .#........#
      #.##...#...
      #...##....#
      .#..#...#.#
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 7
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 336
  end
end
