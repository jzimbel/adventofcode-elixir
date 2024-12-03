defmodule AdventOfCode.Solution.Year2024.Day02Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day02

  setup do
    [
      input: """
      7 6 4 2 1
      1 2 7 8 9
      9 7 6 2 1
      1 3 2 4 5
      8 6 4 4 1
      1 3 6 7 9
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result == 2
  end

  test "part2", %{input: input} do
    result = input |> parse() |> part2()

    assert result == 4
  end
end
