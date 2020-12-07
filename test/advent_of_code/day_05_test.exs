defmodule AdventOfCode.Day05Test do
  use ExUnit.Case

  import AdventOfCode.Day05

  setup_all do
    [
      input: """
      FBFBBFFRLR
      BFFFBBFRRR
      FFFBBBFRRR
      BBFFBBFRLL
      """
    ]
  end

  describe "part1" do
    test "individual", %{input: input} do
      [a, b, c, d] = String.split(input)

      assert part1(a) == 357
      assert part1(b) == 567
      assert part1(c) == 119
      assert part1(d) == 820
    end

    test "overall", %{input: input} do
      result = part1(input)

      assert result == 820
    end
  end

  # no test for part 2
  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
