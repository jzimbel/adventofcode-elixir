defmodule AdventOfCode.Solution.Year2022.Day08Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2022.Day08

  setup do
    [
      input: """
      30373
      25512
      65332
      33549
      35390
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 21
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 8
  end
end
