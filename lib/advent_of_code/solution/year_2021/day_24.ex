defmodule AdventOfCode.Solution.Year2021.Day24 do
  ### NOTE: Incomplete.
  ### NOTE: Part 1 solution is too inefficient.

  def part1(input) do
    input
    |> parse_program()
    |> then(fn program ->
      Enum.find(stream_model_numbers_desc(), &(program.(&1).z == 0))
    end)
  end

  def part2(_input) do
  end

  defp stream_model_numbers_desc(start \\ 99_999_999_999_999) do
    start
    |> Stream.iterate(&(&1 - 1))
    |> Stream.map(&:io_lib.format("~14..0B", [&1]))
    |> Stream.map(fn chars -> Enum.map(chars, &(&1 - ?0)) end)
    |> Stream.reject(&Enum.member?(&1, 0))
  end

  defp get_instr({:inp, [a]}) do
    fn {mem, [input | inputs]} -> {%{mem | a => input}, inputs} end
  end

  defp get_instr({:add, [a, b]}) when is_atom(b) do
    fn {mem, inputs} -> {%{mem | a => Map.fetch!(mem, a) + Map.fetch!(mem, b)}, inputs} end
  end

  defp get_instr({:mul, [a, b]}) when is_atom(b) do
    fn {mem, inputs} -> {%{mem | a => Map.fetch!(mem, a) * Map.fetch!(mem, b)}, inputs} end
  end

  defp get_instr({:div, [a, b]}) when is_atom(b) do
    fn {mem, inputs} -> {%{mem | a => div(Map.fetch!(mem, a), Map.fetch!(mem, b))}, inputs} end
  end

  defp get_instr({:mod, [a, b]}) when is_atom(b) do
    fn {mem, inputs} -> {%{mem | a => rem(Map.fetch!(mem, a), Map.fetch!(mem, b))}, inputs} end
  end

  defp get_instr({:eql, [a, b]}) when is_atom(b) do
    fn {mem, inputs} ->
      {%{mem | a => if(Map.fetch!(mem, a) == Map.fetch!(mem, b), do: 1, else: 0)}, inputs}
    end
  end

  defp get_instr({:add, [a, b]}) do
    fn {mem, inputs} -> {%{mem | a => Map.fetch!(mem, a) + b}, inputs} end
  end

  defp get_instr({:mul, [a, b]}) do
    fn {mem, inputs} -> {%{mem | a => Map.fetch!(mem, a) * b}, inputs} end
  end

  defp get_instr({:div, [a, b]}) do
    fn {mem, inputs} -> {%{mem | a => div(Map.fetch!(mem, a), b)}, inputs} end
  end

  defp get_instr({:mod, [a, b]}) do
    fn {mem, inputs} -> {%{mem | a => rem(Map.fetch!(mem, a), b)}, inputs} end
  end

  defp get_instr({:eql, [a, b]}) do
    fn {mem, inputs} ->
      {%{mem | a => if(Map.fetch!(mem, a) == b, do: 1, else: 0)}, inputs}
    end
  end

  def parse_program(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instr/1)
    |> Enum.reduce(&{%{w: 0, x: 0, y: 0, z: 0}, &1}, fn instr, program ->
      instr = get_instr(instr)

      &instr.(program.(&1))
    end)
    |> then(&fn input -> elem(&1.(input), 0) end)
  end

  defp parse_instr(instr) do
    [op | args] = String.split(instr)
    {String.to_existing_atom(op), Enum.map(args, &parse_arg/1)}
  end

  defp parse_arg(arg) when arg in ~w[w x y z], do: String.to_existing_atom(arg)

  defp parse_arg(n), do: String.to_integer(n)
end
