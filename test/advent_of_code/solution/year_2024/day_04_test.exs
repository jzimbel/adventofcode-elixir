defmodule AdventOfCode.Solution.Year2024.Day04Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day04

  setup do
    [
      input: """
      MMMSXXMASM
      MSAMXMSMSA
      AMXSXMAAMM
      MSAMASMSMX
      XMASAMXAMM
      XXAMMXXAMA
      SMSMSASXSS
      SAXAMASAAA
      MAMMMXMMMM
      MXMXAXMASX
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse |> part1()

    assert result == 18
  end

  test "part2", %{input: input} do
    result = input |> parse |> part2()

    assert result
  end
end
