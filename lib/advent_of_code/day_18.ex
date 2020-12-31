defmodule AdventOfCode.Day18 do
  def part1(args) do
    args
    |> parse_input()
    |> Enum.map(&evaluate(&1, :p1))
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> parse_input()
    |> Enum.map(&evaluate(&1, :p2))
    |> Enum.sum()
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.replace(&1, " ", ""))
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&nest_quantities/1)
  end

  defp nest_quantities(expr, acc \\ [])

  defp nest_quantities([], acc), do: Enum.reverse(acc)

  defp nest_quantities([?) | rest], acc) do
    {Enum.reverse(acc), rest}
  end

  defp nest_quantities([?( | rest], acc) do
    {quantity, rest} = nest_quantities(rest)

    nest_quantities(rest, [quantity | acc])
  end

  defp nest_quantities([char | rest], acc) do
    nest_quantities(rest, [char | acc])
  end

  ###

  defp evaluate(expr, acc \\ {0, &+/2}, p_flag)

  defp evaluate([n | expr], {l, op}, p_flag) when n in ?0..?9 do
    r = n - ?0
    evaluate(expr, {op.(l, r), nil}, p_flag)
  end

  defp evaluate([?+ | expr], {l, _}, p_flag) do
    evaluate(expr, {l, &+/2}, p_flag)
  end

  defp evaluate([?* | expr], {l, _}, :p1) do
    evaluate(expr, {l, &*/2}, :p1)
  end

  defp evaluate([?* | expr], {l, _}, :p2) do
    l * evaluate(expr, :p2)
  end

  defp evaluate([quantity | expr], {l, op}, p_flag) when is_list(quantity) do
    r = evaluate(quantity, p_flag)
    evaluate(expr, {op.(l, r), nil}, p_flag)
  end

  defp evaluate([], {n, _}, _), do: n
end
