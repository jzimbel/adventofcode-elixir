defmodule AdventOfCode.Solution.Year2024.Day03Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day03

  setup do
    [
      input1: """
      xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
      """,
      input2: """
      xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
      """
    ]
  end

  test "part1", %{input1: input} do
    result = input |> parse() |> part1()

    assert result == 161
  end

  test "part2", %{input2: input} do
    result = input |> parse() |> part2()

    assert result == 48
  end
end
