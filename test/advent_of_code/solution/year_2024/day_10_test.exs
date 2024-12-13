defmodule AdventOfCode.Solution.Year2024.Day10Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day10

  setup do
    [
      input1: """
      0123
      1234
      8765
      9876
      """,
      input2: """
      ...0...
      ...1...
      ...2...
      6543456
      7.....7
      8.....8
      9.....9
      """,
      input3: """
      ..90..9
      ...1.98
      ...2..7
      6543456
      765.987
      876....
      987....
      """,
      input4: """
      .....0.
      ..4321.
      ..5..2.
      ..6543.
      ..7..4.
      ..8765.
      ..9....
      """,
      input5: """
      ..90..9
      ...1.98
      ...2..7
      6543456
      765.987
      876....
      987....
      """,
      input6: """
      012345
      123456
      234567
      345678
      4.6789
      56789.
      """,
      input7: """
      89010123
      78121874
      87430965
      96549874
      45678903
      32019012
      01329801
      10456732
      """
    ]
  end

  test "part1", ctx do
    assert ctx.input1 |> parse() |> part1() == 1
    assert ctx.input2 |> parse() |> part1() == 2
    assert ctx.input3 |> parse() |> part1() == 4
  end

  test "part2", ctx do
    assert ctx.input4 |> parse() |> part2() == 3
    assert ctx.input5 |> parse() |> part2() == 13
    assert ctx.input6 |> parse() |> part2() == 227
    assert ctx.input7 |> parse() |> part2() == 81
  end
end
