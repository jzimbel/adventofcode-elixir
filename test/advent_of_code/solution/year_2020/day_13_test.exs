defmodule AdventOfCode.Solution.Year2020.Day13Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2020.Day13

  setup_all do
    [
      input: """
      939
      7,13,x,x,59,x,31,19
      """,
      input2: "x\n17,x,13,19",
      input3: "x\n67,7,59,61",
      input4: "x\n67,x,7,59,61",
      input5: "x\n67,7,x,59,61",
      input6: "x\n1789,37,47,1889"
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 295
  end

  test "part2", ctx do
    assert part2(ctx.input) == 1_068_781
    assert part2(ctx.input2) == 3417
    assert part2(ctx.input3) == 754_018
    assert part2(ctx.input4) == 779_210
    assert part2(ctx.input5) == 1_261_476
    assert part2(ctx.input6) == 1_202_161_486
  end
end
