defmodule AdventOfCode.Solution.Year2022.Day01Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2022.Day01

  setup do
    [
      input: """
      1000
      2000
      3000

      4000

      5000
      6000

      7000
      8000
      9000

      10000
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 24000
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 45000
  end
end
