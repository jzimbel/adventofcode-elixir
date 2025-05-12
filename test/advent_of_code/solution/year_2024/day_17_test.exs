defmodule AdventOfCode.Solution.Year2024.Day17Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day17

  defp make_input(a, program) do
    """
    Register A: #{a}
    Register B: 0
    Register C: 0

    Program: #{program}
    """
  end

  test "part1" do
    input = make_input(729, "0,1,5,4,3,0")
    result = input |> parse() |> part1()

    assert result == "4,6,3,5,6,3,5,2,1,0"
  end

  test "part2" do
    # Part 2 solution is specific to the input program, which has the following characteristics:
    # - Prints once per "loop"
    # - Each iteration of the loop bit-shifts A right by 3 bits
    #
    # The test program here needs to have the same characteristics.
    # This one does the following:
    # 2,4 - b <- a<<3
    # 1,5 - b <- xor 0b101  # This was necessary to make quine_a produce the final 0, idk why
    # 5,5 - OUT <- b % 8
    # 0,3 - a <- a<<3
    # 3,0 - JANZ 0
    program = "2,4,1,5,5,5,0,3,3,0"

    input = make_input(0, program)
    quine_a = input |> parse() |> part2()

    # quine_a should be composed of 10 octets,
    # one for each number in the program.
    assert String.length(Integer.to_string(quine_a, 8)) == 10

    successive_outputs =
      program
      |> Stream.iterate(&(make_input(quine_a, &1) |> parse() |> part1()))
      |> Enum.take(10)

    assert Enum.all?(successive_outputs, &(&1 == program))
  end
end
