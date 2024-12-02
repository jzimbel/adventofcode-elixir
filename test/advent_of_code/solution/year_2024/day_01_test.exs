defmodule AdventOfCode.Solution.Year2024.Day01Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day01
  require Explorer.DataFrame, as: DF

  setup do
    [
      input: """
      3   4
      4   3
      2   5
      1   3
      3   9
      3   3
      """
    ]
  end

  test "parse", %{input: input} do
    df = parse(input)

    assert %{a: [3, 4, 2, 1, 3, 3], b: [4, 3, 5, 3, 9, 3]} == DF.to_columns(df, atom_keys: true)
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result == 11
  end

  test "part2", %{input: input} do
    result = input |> parse() |> part2()

    assert result == 31
  end
end
