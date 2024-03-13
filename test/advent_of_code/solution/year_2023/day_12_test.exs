defmodule AdventOfCode.Solution.Year2023.Day12Test do
  use ExUnit.Case, async: false

  import AdventOfCode.Solution.Year2023.Day12

  setup do
    [
      input: """
      ???.### 1,1,3
      .??..??...?##. 1,1,3
      ?#?#?#?#?#?#?#? 1,3,1,6
      ????.#...#... 4,1,1
      ????.######..#####. 1,6,5
      ?###???????? 3,2,1
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result == 21
  end

  test "part2", %{input: input} do
    result = input |> parse() |> part2()
    assert result == 525_152

    parsed_lines = parse(input)
    result_split = Enum.map(parsed_lines, &part2([&1]))
    assert result_split == [1, 16384, 1, 16, 2500, 506_250]
  end
end
