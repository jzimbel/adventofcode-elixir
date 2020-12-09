defmodule AdventOfCode.Day08 do
  defmodule Bootcode do
    @enforce_keys ~w[instrs i acc seen_i max_i]a
    defstruct @enforce_keys

    def new(instrs_string) do
      instrs = parse_instructions(instrs_string)

      %Bootcode{
        instrs: instrs,
        i: 0,
        acc: 0,
        seen_i: MapSet.new(),
        max_i: Enum.max(Map.keys(instrs))
      }
    end

    def run(%Bootcode{} = t) do
      cond do
        t.i in t.seen_i ->
          {:loop, t.acc}

        t.i == t.max_i + 1 ->
          {:exit, t.acc}

        true ->
          t.instrs[t.i]
          |> execute_instruction(t)
          |> run()
      end
    end

    def swap_op_at(%Bootcode{} = t, index) do
      %{t | instrs: %{t.instrs | index => swap_op(t.instrs[index])}}
    end

    defp parse_instructions(instrs_string) do
      instrs_string
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.split/1)
      |> Enum.map(fn [op, arg] -> {String.to_existing_atom(op), String.to_integer(arg)} end)
      |> Enum.with_index()
      |> Enum.into(%{}, fn {instr, i} -> {i, instr} end)
    end

    defp execute_instruction({:acc, n}, t) do
      %{t | i: t.i + 1, acc: t.acc + n, seen_i: MapSet.put(t.seen_i, t.i)}
    end

    defp execute_instruction({:jmp, n}, t) do
      %{t | i: t.i + n, seen_i: MapSet.put(t.seen_i, t.i)}
    end

    defp execute_instruction({:nop, _}, t) do
      %{t | i: t.i + 1, seen_i: MapSet.put(t.seen_i, t.i)}
    end

    defp swap_op({:nop, n}), do: {:jmp, n}
    defp swap_op({:jmp, n}), do: {:nop, n}
  end

  def part1(args) do
    {:loop, acc} =
      args
      |> Bootcode.new()
      |> Bootcode.run()

    acc
  end

  def part2(args) do
    original = Bootcode.new(args)

    original.instrs
    |> Enum.reject(&match?({_, {:acc, _}}, &1))
    |> Enum.map(fn {i, _} -> i end)
    |> Enum.find_value(&run_swapped(original, &1))
  end

  defp run_swapped(bootcode, swap_index) do
    bootcode
    |> Bootcode.swap_op_at(swap_index)
    |> Bootcode.run()
    |> case do
      {:exit, acc} -> acc
      _ -> false
    end
  end
end
