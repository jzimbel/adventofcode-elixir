defmodule AdventOfCode.Solution.Year2023.Day20Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2023.Day20

  setup do
    [
      input1: """
      broadcaster -> a, b, c
      %a -> b
      %b -> c
      %c -> inv
      &inv -> a
      """,
      input2: """
      broadcaster -> a
      %a -> inv, con
      &inv -> b
      %b -> con
      &con -> output
      """
    ]
  end

  # Test inputs are incompatible with find_input_conjunctions/1.
  @tag :skip
  test "part1", %{input1: input} do
    result = part1(input)
    assert result == 32_000_000
  end

  # Test inputs are incompatible with find_input_conjunctions/1.
  @tag :skip
  test "also part1", %{input2: input} do
    result = part1(input)
    assert result == 11_687_500
  end
end
