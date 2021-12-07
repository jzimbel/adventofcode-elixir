defmodule AdventOfCode.Solution.Year2020.Day18Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2020.Day18

  setup_all do
    [
      input1: "1 + 2 * 3 + 4 * 5 + 6",
      input2: "1 + (2 * 3) + (4 * (5 + 6))",
      input3: "2 * 3 + (4 * 5)",
      input4: "5 + (8 * 3 + 9 + 3 * 4 * 3)",
      input5: "5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))",
      input6: "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"
    ]
  end

  test "part1", ctx do
    assert part1(ctx.input1) == 71
    assert part1(ctx.input2) == 51
    assert part1(ctx.input3) == 26
    assert part1(ctx.input4) == 437
    assert part1(ctx.input5) == 12240
    assert part1(ctx.input6) == 13632
  end

  test "part2", ctx do
    assert part2(ctx.input1) == 231
    assert part2(ctx.input2) == 51
    assert part2(ctx.input3) == 46
    assert part2(ctx.input4) == 1445
    assert part2(ctx.input5) == 669_060
    assert part2(ctx.input6) == 23340
  end
end
