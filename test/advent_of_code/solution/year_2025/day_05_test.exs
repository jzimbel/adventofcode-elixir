defmodule AdventOfCode.Solution.Year2025.Day05Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2025.Day05

  setup do
    [
      input: """
      3-5
      10-14
      16-20
      12-18

      1
      5
      8
      11
      17
      32
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result == 3
  end

  test "part2", %{input: input} do
    result = input |> parse() |> part2()

    assert result == 14
  end
end
