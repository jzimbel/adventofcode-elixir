defmodule AdventOfCode.Solution.Year2025.Day06Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2025.Day06

  setup do
    [
      # Careful when saving--formatter strips trailing spaces which are necessary
      input: """
      123 328  51 64 
       45 64  387 23 
        6 98  215 314
      *   +   *   +  
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 4_277_556
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 3_263_827
  end
end
