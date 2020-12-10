defmodule AdventOfCode.Day09Test do
  use ExUnit.Case

  import AdventOfCode.Day09

  setup_all do
    [
      input: """
      35
      20
      15
      25
      47
      40
      62
      55
      65
      95
      102
      117
      150
      182
      127
      219
      299
      277
      309
      576
      """,
      preamble_length: 5
    ]
  end

  test "part1", %{input: input, preamble_length: preamble_length} do
    result = part1(input, preamble_length)

    assert result == 127
  end

  test "part2", %{input: input, preamble_length: preamble_length} do
    result = part2(input, preamble_length)

    assert result == 62
  end
end
