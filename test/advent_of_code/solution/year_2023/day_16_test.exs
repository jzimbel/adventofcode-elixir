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
    result = input |> parse() |> part1()

    assert result == 46
  end

  test "part2", %{input: input} do
    result = input |> parse() |> part2()

    assert result == 51
  end
end
