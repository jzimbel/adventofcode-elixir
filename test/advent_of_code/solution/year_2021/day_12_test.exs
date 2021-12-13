defmodule AdventOfCode.Solution.Year2021.Day12Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day12

  setup do
    [
      input_smol: """
      start-A
      start-b
      A-c
      A-b
      b-d
      A-end
      b-end
      """,
      input_med: """
      dc-end
      HN-start
      start-kj
      dc-start
      dc-HN
      LN-dc
      HN-end
      kj-sa
      kj-HN
      kj-dc
      """,
      input_beeg: """
      fs-end
      he-DX
      fs-he
      start-DX
      pj-DX
      end-zg
      zg-sl
      zg-pj
      pj-he
      RW-he
      fs-DX
      pj-RW
      zg-RW
      start-pj
      he-WI
      zg-he
      pj-fs
      start-RW
      """
    ]
  end

  test "part1", context do
    assert 10 == part1(context.input_smol)
    assert 19 == part1(context.input_med)
    assert 226 == part1(context.input_beeg)
  end

  test "part2", context do
    assert 36 == part2(context.input_smol)
    assert 103 == part2(context.input_med)
    assert 3509 == part2(context.input_beeg)
  end
end
