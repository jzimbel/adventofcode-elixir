defmodule AdventOfCode.Solution.Year2023.Day16Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2023.Day16

  setup do
    [
      input: ~S"""
      .|...\....
      |.-.\.....
      .....|-...
      ........|.
      ..........
      .........\
      ..../.\\..
      .-.-/..|..
      .|....-|.\
      ..//.|....
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 46
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 51
  end
end
