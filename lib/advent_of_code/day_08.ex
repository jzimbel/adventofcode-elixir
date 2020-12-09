defmodule AdventOfCode.Day08 do
  defmodule Bootcode do
    @enforce_keys ~w[instrs i acc]a
    defstruct @enforce_keys

    def new(instrs_string) do
      %Bootcode{instrs: parse_instructions(instrs_string), i: 0, acc: 0}
    end

    def run(%Bootcode{} = t, visited \\ MapSet.new()) do
      cond do
        t.i in visited ->
          {:loop, t.acc}

        t.i == map_size(t.instrs) ->
          {:exit, t.acc}

        true ->
          t.instrs[t.i]
          |> execute_instruction(t)
          |> run(MapSet.put(visited, t.i))
      end
    end

    def run_swapped(%Bootcode{} = t, swap_index) do
      t
      |> swap_op_at(swap_index)
      |> run()
    end

    defp parse_instructions(instrs_string) do
      instrs_string
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split/1)
      |> Enum.map(fn [op, arg] ->
        {String.to_existing_atom(op), String.to_integer(arg)}
      end)
      |> Enum.with_index()
      |> Enum.into(%{}, fn {instr, i} -> {i, instr} end)
    end

    defp execute_instruction({:acc, n}, t) do
      %{t | i: t.i + 1, acc: t.acc + n}
    end

    defp execute_instruction({:jmp, n}, t) do
      %{t | i: t.i + n}
    end

    defp execute_instruction({:nop, _}, t) do
      %{t | i: t.i + 1}
    end

    defp swap_op_at(t, i) do
      %{t | instrs: %{t.instrs | i => swap_op(t.instrs[i])}}
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
    |> Stream.reject(&match?({_, {:acc, _}}, &1))
    |> Stream.map(fn {i, _} -> i end)
    |> Stream.map(&Bootcode.run_swapped(original, &1))
    |> Enum.find_value(fn
      {:exit, acc} -> acc
      _ -> false
    end)
  end
end
