defmodule AdventOfCode.Solution.Year2022.Day11 do
  defmodule Monkey do
    @type item :: non_neg_integer
    @type id :: 0..9

    @type t :: %__MODULE__{
            items: list(item),
            inspect_fn: (item -> item),
            divisor: pos_integer,
            true_dest: id,
            false_dest: id,
            counter: non_neg_integer
          }

    defstruct [:items, :inspect_fn, :divisor, :true_dest, :false_dest, counter: 0]

    @spec new(String.t()) :: {id, t()}
    def new(descriptor) do
      descriptor
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.reduce(%{}, &parse_line/2)
      |> then(fn map -> {map.id, struct!(__MODULE__, Map.delete(map, :id))} end)
    end

    defp parse_line(<<"Monkey ", id, ":">>, acc) do
      Map.put_new(acc, :id, id - ?0)
    end

    defp parse_line(<<"Starting items: ", items::binary>>, acc) do
      items
      |> String.split(", ")
      |> Enum.map(&String.to_integer/1)
      |> then(&Map.put_new(acc, :items, &1))
    end

    defp parse_line(<<"Operation: new = ", op::binary>>, acc) do
      if safe?(op) do
        q_op = Code.string_to_quoted!(op)

        Map.put_new(acc, :inspect_fn, fn old ->
          {new, _} = Code.eval_quoted(q_op, old: old)
          new
        end)
      else
        raise "I ain't eval-ing that"
      end
    end

    defp parse_line(<<"Test: divisible by ", divisor_str::binary>>, acc) do
      Map.put_new(acc, :divisor, String.to_integer(divisor_str))
    end

    defp parse_line(<<"If true: throw to monkey ", id>>, acc) do
      Map.put_new(acc, :true_dest, id - ?0)
    end

    defp parse_line(<<"If false: throw to monkey ", id>>, acc) do
      Map.put_new(acc, :false_dest, id - ?0)
    end

    defp safe?(op) do
      Regex.match?(~r/^old (?:\+|\*) (?:old|\d+)$/, op)
    end
  end

  def part1(input), do: solve(input, true, 20)
  def part2(input), do: solve(input, false, 10_000)

  defp solve(input, div?, rounds) do
    monkeys =
      input
      |> String.split("\n\n", trim: true)
      |> Map.new(&Monkey.new/1)

    limit = get_limit(monkeys)

    monkeys
    |> Stream.iterate(&do_round(&1, limit, div?))
    |> Enum.at(rounds)
    |> Enum.map(fn {_id, monkey} -> monkey.counter end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  defp get_limit(monkeys) do
    monkeys
    |> Map.values()
    |> Enum.map(& &1.divisor)
    |> Enum.product()
  end

  defp do_round(monkeys, limit, div?) do
    Enum.reduce(0..(map_size(monkeys) - 1)//1, monkeys, &do_turn(&1, &2, limit, div?))
  end

  @spec do_turn(Monkey.id(), %{Monkey.id() => Monkey.t()}, pos_integer, boolean) :: %{
          Monkey.id() => Monkey.t()
        }
  def do_turn(id, monkeys, limit, div?) do
    %{
      items: items,
      inspect_fn: inspect_fn,
      divisor: divisor,
      true_dest: true_dest,
      false_dest: false_dest,
      counter: counter
    } = monkeys[id]

    monkeys = update_in(monkeys[id], &%{&1 | items: [], counter: counter + length(items)})

    Enum.reduce(items, monkeys, fn item, acc ->
      item =
        item
        |> inspect_fn.()
        |> then(if(div?, do: &div(&1, 3), else: & &1))
        |> rem(limit)

      throw_to = if rem(item, divisor) == 0, do: true_dest, else: false_dest

      update_in(acc[throw_to].items, &(&1 ++ [item]))
    end)
  end
end
