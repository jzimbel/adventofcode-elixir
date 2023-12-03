defmodule AdventOfCode.Solution.Year2023.Day03Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2023.Day03

  setup do
    [
      input: """
      467..114..
      ...*......
      ..35...633
      617....#..
      ...*......
      .....+.58.
      ..592.....
      ......755.
      ...$.*....
      .664.598..
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 4361
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 467_835
  end
end
