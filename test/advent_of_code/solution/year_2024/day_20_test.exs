defmodule AdventOfCode.Solution.Year2024.Day20Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day20

  setup do
    [
      input: """
      ###############
      #...#...#.....#
      #.#.#.#.#.###.#
      #S#...#.#.#...#
      #######.#.#.###
      #######.#.#...#
      #######.#.###.#
      ###..E#...#...#
      ###.#######.###
      #...###...#...#
      #.#####.#.###.#
      #.#...#.#.#...#
      #.#.#.#.#.#.###
      #...#...#...###
      ###############
      """
    ]
  end

  test "part1", %{input: input} do
    expected_freqs =
      %{
        2 => 14,
        4 => 14,
        6 => 2,
        8 => 4,
        10 => 2,
        12 => 3,
        20 => 1,
        36 => 1,
        38 => 1,
        40 => 1,
        64 => 1
      }

    result =
      input
      |> parse()
      |> solve(2)
      |> Enum.frequencies()

    assert result == expected_freqs
  end

  test "part2", %{input: input} do
    expected_freqs = %{
      50 => 32,
      52 => 31,
      54 => 29,
      56 => 39,
      58 => 25,
      60 => 23,
      62 => 20,
      64 => 19,
      66 => 12,
      68 => 14,
      70 => 12,
      72 => 22,
      74 => 4,
      76 => 3
    }

    result =
      input
      |> parse()
      |> solve(20)
      |> Enum.frequencies()
      |> Map.filter(fn {k, _} -> k >= 50 end)

    assert result == expected_freqs
  end
end
