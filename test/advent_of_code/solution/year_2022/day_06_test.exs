defmodule AdventOfCode.Solution.Year2022.Day06Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2022.Day06

  setup do
    [
      input: "bvwbjplbgvbhsrlpgdmjqwftvncz"
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 5
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 23
  end
end
