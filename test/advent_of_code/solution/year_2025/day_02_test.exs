defmodule AdventOfCode.Solution.Year2025.Day02Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2025.Day02

  setup do
    [
      input: """
      11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result == 1_227_775_554
  end

  test "part2", %{input: input} do
    result = input |> parse() |> part2()

    assert result == 4_174_379_265
  end
end
