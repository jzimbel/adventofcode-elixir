defmodule AdventOfCode.Solution.Year2024.Day07 do
  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input) do
    for line <- String.split(input, "\n", trim: true) do
      [target, ns] = String.split(line, ":")
      {String.to_integer(target), for(n <- String.split(ns), do: String.to_integer(n))}
    end
  end

  def part1(equations), do: solve(equations, 2)
  def part2(equations), do: solve(equations, 3)

  defp solve(eqs, n_ops) do
    for {target, _ns} = eq <- eqs, solvable?(eq, n_ops), reduce: 0, do: (acc -> acc + target)
  end

  def solvable?({target, ns}, n_ops) do
    ns
    |> stream_calculations(n_ops)
    |> Enum.any?(&(&1 == target))
  end

  def stream_calculations([], _n_ops), do: []
  def stream_calculations([n], _n_ops), do: [n]

  def stream_calculations(ns, n_ops) do
    upper_bound = n_ops ** (length(ns) - 1)

    Stream.unfold(0, fn
      ^upper_bound -> nil
      op_combo -> {apply_ops(op_combo, ns, n_ops), op_combo + 1}
    end)
  end

  defp apply_ops(op_combo, ns, n_ops) do
    op_combo
    |> Integer.digits(n_ops)
    |> zero_pad(length(ns))
    |> Enum.zip_reduce(ns, 0, &eval_op/3)
  end

  defp zero_pad(l, n), do: List.duplicate(0, max(0, n - length(l))) ++ l

  defp eval_op(0, b, a), do: a + b
  defp eval_op(1, b, a), do: a * b
  defp eval_op(2, b, a), do: a * 10 ** (1 + trunc(:math.log10(b))) + b
end
