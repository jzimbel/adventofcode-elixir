defmodule AdventOfCode.Solution.Year2024.Day16Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day16

  setup do
    [
      input1: """
      ###############
      #.......#....E#
      #.#.###.#.###.#
      #.....#.#...#.#
      #.###.#####.#.#
      #.#.#.......#.#
      #.#.#####.###.#
      #...........#.#
      ###.#.#####.#.#
      #...#.....#.#.#
      #.#.#.###.#.#.#
      #.....#...#.#.#
      #.###.#.#.#.#.#
      #S..#.....#...#
      ###############
      """,
      input2: """
      #################
      #...#...#...#..E#
      #.#.#.#.#.#.#.#.#
      #.#.#.#...#...#.#
      #.#.#.#.###.#.#.#
      #...#.#.#.....#.#
      #.#.#.#.#.#####.#
      #.#...#.#.#.....#
      #.#.#####.#.###.#
      #.#.#.......#...#
      #.#.###.#####.###
      #.#.#...#.....#.#
      #.#.#.#####.###.#
      #.#.#.........#.#
      #.#.#.#########.#
      #S#.............#
      #################
      """
    ]
  end

  test "part1", %{input1: input1, input2: input2} do
    result = input1 |> parse() |> part1()
    assert result == 7036

    result = input2 |> parse() |> part1()
    assert result == 11048
  end

  test "part2", %{input1: input1, input2: input2} do
    result = input1 |> parse() |> part2()
    assert result == 45

    result = input2 |> parse() |> part2()
    assert result == 64
  end
end
