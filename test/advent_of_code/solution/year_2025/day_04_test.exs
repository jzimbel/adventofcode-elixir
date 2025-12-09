defmodule AdventOfCode.Solution.Year2025.Day04Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2025.Day04

  setup do
    [
      input: """
      ..@@.@@@@.
      @@@.@.@.@@
      @@@@@.@.@@
      @.@@@@..@.
      @@.@@@@.@@
      .@@@@@@@.@
      .@.@.@.@@@
      @.@@@.@@@@
      .@@@@@@@@.
      @.@.@@@.@.
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result == 13
  end

  test "part2", %{input: input} do
    result = input |> parse() |> part2()

    assert result == 43
  end
end
