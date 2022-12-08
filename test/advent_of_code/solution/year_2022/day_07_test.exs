defmodule AdventOfCode.Solution.Year2022.Day07Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2022.Day07

  setup do
    [
      input: """
      $ cd /
      $ ls
      dir a
      14848514 b.txt
      8504156 c.dat
      dir d
      $ cd a
      $ ls
      dir e
      29116 f
      2557 g
      62596 h.lst
      $ cd e
      $ ls
      584 i
      $ cd ..
      $ cd ..
      $ cd d
      $ ls
      4060174 j
      8033020 d.log
      5626152 d.ext
      7214296 k
      """
    ]
  end

  test "part1", %{input: input} do
    result = part1(input)

    assert result == 95437
  end

  test "part2", %{input: input} do
    result = part2(input)

    assert result == 24_933_642
  end
end
