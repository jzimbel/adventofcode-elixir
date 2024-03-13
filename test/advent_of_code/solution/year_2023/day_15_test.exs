defmodule AdventOfCode.Solution.Year2023.Day15Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2023.Day15

  setup do
    [
      input: """
      rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result == 1320
  end

  test "part2", %{input: input} do
    result = input |> parse() |> part2()

    assert result == 145
  end
end
