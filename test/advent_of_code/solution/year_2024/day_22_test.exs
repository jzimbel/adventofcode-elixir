defmodule AdventOfCode.Solution.Year2024.Day22Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day22

  setup do
    [
      input1: """
      1
      10
      100
      2024
      """,
      input2: """
      1
      2
      3
      2024
      """
    ]
  end

  test "part1", %{input1: input} do
    result = input |> parse() |> part1()

    assert result == 37_327_623
  end

  test "part2", %{input2: input} do
    result = input |> parse() |> part2()

    assert result == 23
  end
end
