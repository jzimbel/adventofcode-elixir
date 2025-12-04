defmodule AdventOfCode.Solution.Year2025.Day03 do
  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input) do
    input
    |> String.split()
    |> Enum.map(&for(d <- String.to_charlist(&1), do: d - ?0))
  end

  def part1(battery_banks), do: Enum.sum_by(battery_banks, &max_jolt(&1, 2))
  def part2(battery_banks), do: Enum.sum_by(battery_banks, &max_jolt(&1, 12))

  defp max_jolt(batteries, num_to_activate) do
    bank_size = length(batteries)
    init_active_group = List.duplicate(0, num_to_activate)

    batteries
    # Annotate batteries with the earliest index they can occupy in the activated group
    |> Enum.with_index(fn b, i -> {b, max(num_to_activate + i - bank_size, 0)} end)
    |> Enum.reduce(init_active_group, &update_active_group/2)
    |> Integer.undigits()
  end

  defp update_active_group({b, min_i}, active_group) do
    {ineligible, eligible} = Enum.split(active_group, min_i)
    update_active_group(b, eligible, Enum.reverse(ineligible))
  end

  defp update_active_group(_b, [], acc), do: Enum.reverse(acc)

  defp update_active_group(b, [active | actives], acc) when b > active,
    do: update_active_group(b, [], List.duplicate(0, length(actives)) ++ [b | acc])

  defp update_active_group(b, [active | actives], acc),
    do: update_active_group(b, actives, [active | acc])
end
