defmodule AdventOfCode.Solution.Year2024.Day19 do
  use AdventOfCode.Solution.SharedParse

  @memo __MODULE__.MemoTable

  @impl true
  def parse(input) do
    [towels, patterns] = String.split(input, "\n\n")
    {String.split(towels, ", "), String.split(patterns)}
  end

  def part1(parsed), do: solve(parsed, &if(possible?(&1, &2), do: 1, else: 0))
  def part2(parsed), do: solve(parsed, &count_possible/2)

  defp solve({towels, patterns}, counter) do
    start_memo()

    for {:ok, count} <- Task.async_stream(patterns, &counter.(&1, towels)), reduce: 0 do
      acc -> acc + count
    end
  after
    :ets.delete(@memo)
  end

  defp possible?("", _ts), do: true
  defp possible?(pat, ts), do: memo({pat, :possible?}, &do_possible?/2, pat, ts)

  defp count_possible("", _ts), do: 1
  defp count_possible(pat, ts), do: memo({pat, :count}, &do_count/2, pat, ts)

  defp do_possible?(pat, ts) do
    stream_substrings(ts, pat) |> Enum.any?(&possible?(&1, ts))
  end

  defp do_count(pat, ts) do
    stream_substrings(ts, pat)
    |> Stream.map(&count_possible(&1, ts))
    |> Enum.sum()
  end

  defp stream_substrings(ts, pat) do
    ts
    |> Stream.map(&with(^&1 <> rest <- pat, do: rest, else: (_ -> nil)))
    |> Stream.reject(&is_nil/1)
  end

  defp memo(key, fallback, pat, ts) do
    case :ets.lookup_element(@memo, key, 2, nil) do
      nil -> tap(fallback.(pat, ts), &:ets.insert(@memo, {key, &1}))
      value -> value
    end
  end

  defp start_memo do
    :ets.new(@memo, [
      :named_table,
      :public,
      read_concurrency: true,
      write_concurrency: true,
      decentralized_counters: true
    ])
  end
end
