defmodule AdventOfCode.Solution.Year2023.Day08 do
  alias AdventOfCode.Math

  @type t :: %__MODULE__{
          labels: %{(index :: non_neg_integer) => String.t()},
          step: non_neg_integer,
          zs: MapSet.t(step :: non_neg_integer)
        }
  @enforce_keys [:labels]
  defstruct @enforce_keys ++ [step: 0, zs: MapSet.new()]

  def new(labels) do
    labels
    |> Enum.with_index(fn l, i -> {i, l} end)
    |> Map.new()
    |> then(&%__MODULE__{labels: &1})
  end

  def part1(input) do
    input
    |> parse()
    |> steps_to_z(["AAA"], &(&1 == "ZZZ"))
  end

  def part2(input) do
    input
    |> parse()
    |> steps_to_z(&match?(<<_, _, ?Z>>, &1))
  end

  defp steps_to_z({dirs, map}, done?) do
    steps_to_z({dirs, map}, for(<<_, _, ?A>> = label <- Map.keys(map), do: label), done?)
  end

  defp steps_to_z({dirs, map}, starting_labels, done?) do
    dirs
    |> Stream.cycle()
    |> Enum.reduce_while(new(starting_labels), fn dir, acc ->
      if map_size(acc.labels) == 0 do
        {:halt, acc.zs}
      else
        {:cont, update_acc(acc, map, dir, done?)}
      end
    end)
    |> Math.lcm()
  end

  defp update_acc(acc, map, dir, done?) do
    found_z = Enum.flat_map(acc.labels, fn {i, l} -> if done?.(l), do: [i], else: [] end)

    labels =
      acc.labels
      |> Map.drop(found_z)
      |> Map.new(fn {i, l} -> {i, map[l][dir]} end)

    zs = if match?([_ | _], found_z), do: MapSet.put(acc.zs, acc.step), else: acc.zs

    %{acc | labels: labels, zs: zs, step: acc.step + 1}
  end

  defp parse(input) do
    [dirs, map] = String.split(input, "\n\n")

    dirs = for <<dir::1-bytes <- dirs>>, do: dir |> String.downcase() |> String.to_existing_atom()

    map =
      for <<label::3-bytes, _::4*8, left::3-bytes, _::2*8, right::3-bytes, _::bytes>> <-
            String.split(map, "\n", trim: true),
          into: %{},
          do: {label, %{l: left, r: right}}

    {dirs, map}
  end
end
