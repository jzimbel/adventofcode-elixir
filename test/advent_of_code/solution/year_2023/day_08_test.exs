defmodule AdventOfCode.Solution.Year2023.Day08Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2023.Day08

  setup do
    [
      input1: """
      RL

      AAA = (BBB, CCC)
      BBB = (DDD, EEE)
      CCC = (ZZZ, GGG)
      DDD = (DDD, DDD)
      EEE = (EEE, EEE)
      GGG = (GGG, GGG)
      ZZZ = (ZZZ, ZZZ)
      """,
      input2: """
      LLR

      AAA = (BBB, BBB)
      BBB = (AAA, ZZZ)
      ZZZ = (ZZZ, ZZZ)
      """,
      input3: """
      LR

      11A = (11B, XXX)
      11B = (XXX, 11Z)
      11Z = (11B, XXX)
      22A = (22B, XXX)
      22B = (22C, 22C)
      22C = (22Z, 22Z)
      22Z = (22B, 22B)
      XXX = (XXX, XXX)
      """
    ]
  end

  test "part1", %{input1: input1, input2: input2} do
    result = input1 |> parse() |> part1()
    assert result == 2

    result = input2 |> parse() |> part1()
    assert result == 6
  end

  test "part2", %{input3: input} do
    result = input |> parse() |> part2()

    assert result == 6
  end
end
