defmodule AdventOfCode.Day12Test do
  use ExUnit.Case

  import AdventOfCode.Day12

  setup_all do
    [
      input: """
      F10
      N3
      F7
      R90
      F11
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 25
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
