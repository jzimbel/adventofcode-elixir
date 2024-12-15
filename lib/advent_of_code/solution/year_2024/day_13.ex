defmodule AdventOfCode.Solution.Year2024.Day13 do
  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input) do
    for spec <- String.split(input, "\n\n", trim: true) do
      List.to_tuple(
        for(
          binding <- Regex.run(spec_pat(), spec, capture: :all_but_first),
          do: String.to_integer(binding)
        )
      )
    end
  end

  defp spec_pat do
    ~r"""
    Button A: X\+(\d+), Y\+(\d+)
    Button B: X\+(\d+), Y\+(\d+)
    Prize: X=(\d+), Y=(\d+)\
    """
  end

  def part1(specs) do
    for spec <- specs, t = min_tokens(spec), t != nil, reduce: 0 do
      acc -> acc + t
    end
  end

  def part2(specs) do
    part1(for spec <- specs, do: embiggen(spec))
  end

  defp embiggen({ax, ay, bx, by, x, y}) do
    {ax, ay, bx, by, x + 10_000_000_000_000, y + 10_000_000_000_000}
  end

  defp min_tokens({ax, ay, bx, by, x, y}) do
    # Assumes all inputs are positive and denominator exprs don't evalute to 0.
    # I can't believe this puzzle got me to solve a system of equations by hand.
    with 0 <- rem(ax * y - ay * x, ax * by - ay * bx),
         b_presses = div(ax * y - ay * x, ax * by - ay * bx),
         0 <- rem(x - bx * b_presses, ax),
         a_presses = div(x - bx * b_presses, ax) do
      a_presses * 3 + b_presses
    else
      _ -> nil
    end
  end
end
