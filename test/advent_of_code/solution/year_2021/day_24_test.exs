defmodule AdventOfCode.Solution.Year2021.Day24Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day24

  setup do
    [
      negate: """
      inp x
      mul x -1
      """,
      compare: """
      inp z
      inp x
      mul z 3
      eql z x
      """,
      bin_digits: """
      inp w
      add z w
      mod z 2
      div w 2
      add y w
      mod y 2
      div w 2
      add x w
      mod x 2
      div w 2
      mod w 2
      """
    ]
  end

  test "parse_program", %{negate: negate, compare: compare, bin_digits: bin_digits} do
    negate_prog = parse_program(negate)
    assert %{x: -3} = negate_prog.([3])
    assert %{x: 5} = negate_prog.([-5])

    compare_prog = parse_program(compare)
    assert %{z: 1} = compare_prog.([3, 9])
    assert %{z: 1} = compare_prog.([-8, -24])
    assert %{z: 0} = compare_prog.([3, 2])
    assert %{z: 0} = compare_prog.([-8, -25])

    bin_digits_prog = parse_program(bin_digits)
    assert %{w: 0, x: 0, y: 0, z: 1} = bin_digits_prog.([1])
    assert %{w: 1, x: 0, y: 1, z: 0} = bin_digits_prog.([10])
    assert %{w: 1, x: 0, y: 1, z: 0} = bin_digits_prog.([26])
    assert %{w: 1, x: 1, y: 1, z: 1} = bin_digits_prog.([31])
    assert %{w: 0, x: 0, y: 0, z: 0} = bin_digits_prog.([32])
  end

  @tag :skip
  test "part1", %{input: input} do
    result = part1(input)

    assert result
  end

  @tag :skip
  test "part2", %{input: input} do
    result = part2(input)

    assert result
  end
end
