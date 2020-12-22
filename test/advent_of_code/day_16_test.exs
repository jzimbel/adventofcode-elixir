defmodule AdventOfCode.Day16Test do
  use ExUnit.Case

  import AdventOfCode.Day16

  setup_all do
    [
      input: """
      class: 1-3 or 5-7
      row: 6-11 or 33-44
      seat: 13-40 or 45-50

      your ticket:
      7,1,14

      nearby tickets:
      7,3,47
      40,4,50
      55,2,20
      38,6,12
      """,
      input2: """
      departure: 0-1 or 4-19
      row: 0-5 or 8-19
      seat: 0-13 or 16-19

      your ticket:
      11,12,13

      nearby tickets:
      3,9,18
      15,1,5
      5,14,9
      """,
      input3: """
      class: 0-1 or 4-19
      departure: 0-5 or 8-19
      seat: 0-13 or 16-19

      your ticket:
      11,12,13

      nearby tickets:
      3,9,18
      15,1,5
      5,14,9
      """,
      input4: """
      class: 0-1 or 4-19
      row: 0-5 or 8-19
      departure: 0-13 or 16-19

      your ticket:
      11,12,13

      nearby tickets:
      3,9,18
      15,1,5
      5,14,9
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 71
  end

  test "part2", %{input2: input2, input3: input3, input4: input4} do
    assert part2(input2) == 12
    assert part2(input3) == 11
    assert part2(input4) == 13
  end
end
