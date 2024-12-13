defmodule AdventOfCode.Solution.Year2024.Day12Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day12

  setup do
    [
      input1: """
      AAAA
      BBCD
      BBCC
      EEEC
      """,
      input2: """
      OOOOO
      OXOXO
      OOOOO
      OXOXO
      OOOOO
      """,
      input3: """
      RRRRIICCFF
      RRRRIICCCF
      VVRRRCCFFF
      VVRCCCJFFF
      VVVVCJJCFE
      VVIVCCJJEE
      VVIIICJJEE
      MIIIIIJJEE
      MIIISIJEEE
      MMMISSJEEE
      """,
      input4: """
      EEEEE
      EXXXX
      EEEEE
      EXXXX
      EEEEE
      """,
      input5: """
      AAAAAA
      AAABBA
      AAABBA
      ABBAAA
      ABBAAA
      AAAAAA
      """
    ]
  end

  test "part1", ctx do
    assert ctx.input1 |> parse() |> part1() == 140
    assert ctx.input2 |> parse() |> part1() == 772
    assert ctx.input3 |> parse() |> part1() == 1930
  end

  test "part2", ctx do
    assert ctx.input1 |> parse() |> part2() == 80
    assert ctx.input2 |> parse() |> part2() == 436
    assert ctx.input3 |> parse() |> part2() == 1206
    assert ctx.input4 |> parse() |> part2() == 236
    assert ctx.input5 |> parse() |> part2() == 368
  end
end
