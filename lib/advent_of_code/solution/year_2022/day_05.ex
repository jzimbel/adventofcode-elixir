defmodule AdventOfCode.Solution.Year2022.Day05 do
  def part1(input), do: solve(input, &Enum.reverse/1)
  def part2(input), do: solve(input, &Function.identity/1)

  def solve(input, crane_fn) do
    {stacks, instrs} = parse(input)

    instrs
    |> Enum.reduce(stacks, &move(&1, &2, crane_fn))
    |> Enum.sort_by(fn {stack_label, _stack} -> stack_label end)
    |> Enum.map(fn {_stack_label, [crate | _]} -> crate end)
    |> to_string()
  end

  defp move({source, dest, count}, stacks, crane_fn) do
    {to_move, to_remain} = Enum.split(stacks[source], count)

    stacks
    |> Map.put(source, to_remain)
    |> Map.update!(dest, &Enum.concat(crane_fn.(to_move), &1))
  end

  defp parse(input) do
    [stack_lines, instr_lines] = String.split(input, "\n\n")
    {parse_stacks(stack_lines), parse_instrs(instr_lines)}
  end

  # Assumes crate labels are always 1 char
  # Assumes stack labels are always 1 digit and listed in order: "1 2 ... 9"
  defp parse_stacks(stack_lines) do
    stack_lines
    |> String.split("\n", trim: true)
    # Faster to build lists tail-first
    |> Enum.reverse()
    # Skip last line with stack labels
    |> Enum.drop(1)
    |> Enum.map(&parse_stacks_row/1)
    |> Enum.reduce(fn stacks_row, stacks ->
      Map.merge(stacks, stacks_row, fn _stack_label, stack, [crate] -> [crate | stack] end)
    end)
  end

  defp parse_stacks_row(line) do
    line
    |> String.to_charlist()
    |> Enum.drop(1)
    |> Enum.take_every(4)
    |> Enum.with_index(fn crate, i -> {i + 1, [crate]} end)
    |> Enum.reject(&match?({_stack_label, ' '}, &1))
    |> Map.new()
  end

  defp parse_instrs(instr_lines) do
    instr_lines
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      ~r/^move (\d+) from (\d) to (\d)$/
      |> Regex.run(line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)
      |> then(fn [count, from_label, to_label] -> {from_label, to_label, count} end)
    end)
  end
end
