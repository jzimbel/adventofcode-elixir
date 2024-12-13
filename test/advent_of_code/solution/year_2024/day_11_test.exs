defmodule AdventOfCode.Solution.Year2024.Day11Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day11

  setup do
    [
      input: """
      125 17
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result == 55312
  end

  @tag :skip
  test "part2", %{input: input} do
    result = input |> parse() |> part2()

    assert result
  end
end
