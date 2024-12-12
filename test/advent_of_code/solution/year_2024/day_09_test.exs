defmodule AdventOfCode.Solution.Year2024.Day09Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day09

  setup do
    [
      input: """
      2333133121414131402
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result == 1928
  end

  test "part2", %{input: input} do
    result = input |> parse() |> part2()

    assert result == 2858
  end
end
