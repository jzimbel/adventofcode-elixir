defmodule AdventOfCode.Day15Test do
  use ExUnit.Case

  import AdventOfCode.Day15

  setup_all do
    [
      input1: "0,3,6",
      input2: "1,3,2",
      input3: "2,1,3",
      input4: "1,2,3",
      input5: "2,3,1",
      input6: "3,2,1",
      input7: "3,1,2"
    ]
  end

  test "part1", ctx do
    assert part1(ctx.input1) == 436
    assert part1(ctx.input2) == 1
    assert part1(ctx.input3) == 10
    assert part1(ctx.input4) == 27
    assert part1(ctx.input5) == 78
    assert part1(ctx.input6) == 438
    assert part1(ctx.input7) == 1836
  end

  # skipping in the full suite due to slowness (takes about 35 sec per input)
  @tag :skip
  @tag timeout: 40_000
  test "part2", ctx do
    assert part2(ctx.input1) == 175_594
    # assert part2(ctx.input2) == 2578
    # assert part2(ctx.input3) == 3_544_142
    # assert part2(ctx.input4) == 261_214
    # assert part2(ctx.input5) == 6_895_259
    # assert part2(ctx.input6) == 18
    # assert part2(ctx.input7) == 362
  end
end
