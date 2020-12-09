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

    def run(%Bootcode{instrs: instrs, i: i, seen_i: seen_i, max_i: max_i} = t) do
      cond do
        i in seen_i ->
          {:loop, t}

        i == max_i + 1 ->
          {:exit, t}

        true ->
          instrs[i]
          |> execute_instruction(t)
          |> run()
      end
    end

    defp execute_instruction({:acc, n}, %{i: i, acc: acc, seen_i: seen_i} = t) do
      %{t | i: i + 1, acc: acc + n, seen_i: MapSet.put(seen_i, i)}
    end

    defp execute_instruction({:jmp, n}, %{i: i, seen_i: seen_i} = t) do
      %{t | i: i + n, seen_i: MapSet.put(seen_i, i)}
    end

    defp execute_instruction({:nop, _}, %{i: i, seen_i: seen_i} = t) do
      %{t | i: i + 1, seen_i: MapSet.put(seen_i, i)}
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
  end

  def part1(args) do
    {:loop, halted} =
      args
      |> Bootcode.new()
      |> Bootcode.run()

    halted.acc
  end

  def part2(args) do
    original = Bootcode.new(args)

    swap_candidate_indexes =
      original.instrs
      |> Enum.reject(&match?({_, {:acc, _}}, &1))
      |> Enum.map(fn {i, _} -> i end)

    halted = get_terminated_bootcode(swap_candidate_indexes, original)
    halted.acc
  end

  defp get_terminated_bootcode([swap_index | swap_indexes], original) do
    original
    |> Map.update!(:instrs, &swap_op_at(&1, swap_index))
    |> Bootcode.run()
    |> case do
      {:exit, halted} -> halted
      _ -> get_terminated_bootcode(swap_indexes, original)
    end
  end

  defp swap_op_at(instrs, index) do
    %{instrs | index => swap_op(instrs[index])}
  end

  defp swap_op({:nop, n}), do: {:jmp, n}
  defp swap_op({:jmp, n}), do: {:nop, n}
end
