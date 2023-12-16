defmodule AdventOfCode.Solution.Year2023.Day12 do
  @memo __MODULE__.MemoTable

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(&parse_line/1)
    |> solve()
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(&parse_line/1)
    |> Stream.map(&quintuple/1)
    |> solve()
  end

  defp solve(parsed_lines) do
    :ets.new(@memo, [
      :named_table,
      :public,
      read_concurrency: true,
      write_concurrency: true,
      decentralized_counters: true
    ])

    parsed_lines
    |> Task.async_stream(fn {pat, sizes} -> count_arrangements(pat, sizes) end, ordered: false)
    |> Stream.map(fn {:ok, count} -> count end)
    |> Enum.sum()
  after
    :ets.delete(@memo)
  end

  defp quintuple({pat, sizes}) do
    {Enum.join(List.duplicate(pat, 5), "?"), for(_ <- 1..4, reduce: sizes, do: (l -> sizes ++ l))}
  end

  defp count_arrangements(pat, sizes, offset \\ 0) do
    key = {pat, sizes, offset}

    case :ets.match(@memo, {key, :"$1"}) do
      [[value]] -> value
      [] -> tap(do_count(pat, sizes, offset), &:ets.insert(@memo, {key, &1}))
    end
  end

  defp do_count(pat, [size | _], offset) when byte_size(pat) - offset < size, do: 0

  defp do_count(pat, [], offset) do
    # If there are any '#'s in the remainder of the string, this arrangement is not valid.
    if :binary.match(pat, "#", scope: end_scope(pat, offset)) == :nomatch, do: 1, else: 0
  end

  defp do_count(pat, [size | sizes], offset) do
    {segment_size, dot} = if match?([_ | _], sizes), do: {size + 1, "[?.]"}, else: {size, ""}
    pmax = with {pos, _len} <- :binary.match(pat, "#", scope: end_scope(pat, offset)), do: pos

    ~r"""
    [?\#]   # This is the character that we'll get the index of. The first character of this valid contiguous section.
    (?=     # Positive lookahead. Check that the correct characters follow the start of this contiguous section, without consuming them.
      [?\#]{#{size - 1}}   # Remaining characters of the contiguous section.
      #{dot}                # Optional trailing '.', if this is not the final contiguous section.
    )
    """x
    |> Regex.scan(pat, offset: offset, return: :index)
    |> Enum.reduce(0, fn
      [{pos, _}], sum when pos <= pmax -> sum + count_arrangements(pat, sizes, pos + segment_size)
      _, sum -> sum
    end)
  end

  defp end_scope(pat, offset), do: {byte_size(pat), offset - byte_size(pat)}

  defp parse_line(line) do
    [springs_str, sizes_str] = String.split(line)
    {springs_str, Enum.map(String.split(sizes_str, ","), &String.to_integer/1)}
  end
end
