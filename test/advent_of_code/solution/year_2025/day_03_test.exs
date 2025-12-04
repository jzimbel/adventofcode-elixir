defmodule AdventOfCode.Solution.Year2025.Day03Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2025.Day03

  setup do
    [
      input: """
      987654321111111
      811111111111119
      234234234234278
      818181911112111
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result == 357
  end

  test "part2", %{input: input} do
    result = input |> parse() |> part2()

    assert result == 3_121_910_778_619
  end
end
