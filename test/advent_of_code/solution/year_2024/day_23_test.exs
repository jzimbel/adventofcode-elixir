defmodule AdventOfCode.Solution.Year2024.Day23Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day23

  setup do
    [
      input: """
      kh-tc
      qp-kh
      de-cg
      ka-co
      yn-aq
      qp-ub
      cg-tb
      vc-aq
      tb-ka
      wh-tc
      yn-cg
      kh-ub
      ta-co
      de-co
      tc-td
      tb-wq
      wh-td
      ta-ka
      td-qp
      aq-cg
      wq-ub
      ub-vc
      de-ta
      wq-aq
      wq-vc
      wh-yn
      ka-de
      kh-ta
      co-tc
      wh-qp
      tb-vc
      td-yn
      """
    ]
  end

  test "part1", %{input: input} do
    result = input |> parse() |> part1()

    assert result == 7
  end

  test "part2", %{input: input} do
    result = input |> parse() |> part2()

    assert result == "co,de,ka,ta"
  end
end
