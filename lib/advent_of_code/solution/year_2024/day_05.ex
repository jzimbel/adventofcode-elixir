defmodule AdventOfCode.Solution.Year2024.Day05 do
  use AdventOfCode.Solution.SharedParse

  @typep page :: integer

  @impl true
  @spec parse(String.t()) :: {
          # k comes before all pages in v
          %{page => MapSet.t(page)},
          [[page]]
        }
  def parse(input) do
    [rules, updates] = String.split(input, "\n\n", trim: true)
    {parse_afters(rules), parse_updates(updates)}
  end

  defp parse_afters(rules) do
    for rule <- String.split(rules, "\n", trim: true), reduce: %{} do
      afters ->
        [before, after_] = for page <- String.split(rule, "|"), do: String.to_integer(page)

        afters
        |> Map.update(before, MapSet.new([after_]), &MapSet.put(&1, after_))
        # Adds an entry for the last page (which has no afters)
        |> Map.put_new(after_, MapSet.new())
    end
  end

  defp parse_updates(updates) do
    for update <- String.split(updates, "\n", trim: true) do
      for page <- String.split(update, ",") do
        String.to_integer(page)
      end
    end
  end

  def part1({afters, updates}) do
    for(update <- updates, ordered?(update, afters), do: update)
    |> sum_middles()
  end

  def part2({afters, updates}) do
    for(update <- updates, sorted = sorted_or_nil(update, afters), sorted != nil, do: sorted)
    |> sum_middles()
  end

  defp ordered?(update, afters) do
    update
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(&page_pair_ordered?(&1, afters))
  end

  defp sorted_or_nil(update, afters) do
    case Enum.sort(update, &page_pair_ordered?([&1, &2], afters)) do
      ^update -> nil
      sorted -> sorted
    end
  end

  defp page_pair_ordered?([l, r], afters), do: r in afters[l]

  defp sum_middles(updates) do
    for update <- updates, reduce: 0 do
      acc -> acc + Enum.at(update, div(length(update), 2))
    end
  end
end
