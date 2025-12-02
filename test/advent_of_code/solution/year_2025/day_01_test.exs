defmodule AdventOfCode.Solution.Year2025.Day01Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2025.Day01

  setup do
    [
      input: """
      L68
      L30
      R48
      L5
      R60
      L55
      L1
      L99
      R14
      L82
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result == 3
  end

  test "part2", %{input: input} do
    result = input |> parse() |> part2()

    assert result == 6
  end
end
