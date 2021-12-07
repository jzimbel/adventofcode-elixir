defmodule AdventOfCode.Solution.Year2021.Day06Test do
  use ExUnit.Case

  import AdventOfCode.Solution.Year2021.Day06

  setup do
    [
      input: """
      3,4,3,1,2
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 5934
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 26_984_457_539
  end
end
