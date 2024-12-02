defmodule AdventOfCode.Solution.Year2024.Day01 do
  use AdventOfCode.Solution.SharedParse

  require Explorer.DataFrame, as: DF
  require Explorer.Series, as: S

  @impl true
  def parse(input) do
    input
    |> DF.load_csv!(
      columns: columns_filter(input),
      header: false,
      delimiter: " "
    )
    |> DF.rename([:a, :b])
  end

  def part1(df) do
    df =
      df
      |> DF.mutate(a: S.sort(^df[:a]))
      |> DF.mutate(b: S.sort(^df[:b]))
      |> DF.transform([names: [:a, :b], atom_keys: true], &%{diff: abs(&1.a - &1.b)})

    S.sum(df[:diff])
  end

  def part2(df) do
    a_freq = S.frequencies(df[:a]) |> DF.rename(counts: :a_counts)
    b_freq = S.frequencies(df[:b]) |> DF.rename(counts: :b_counts)

    df =
      DF.join(a_freq, b_freq)
      |> DF.transform(
        [names: [:values, :a_counts, :b_counts], atom_keys: true],
        &%{similarity: &1.values * &1.a_counts * &1.b_counts}
      )

    S.sum(df[:similarity])
  end

  # Input has multiple spaces, Explorer's CSV parser expects single char delimiting
  # columns, so we end up with a handful of blank columns that need to be ignored.
  def columns_filter(input) do
    [l | _ls] = String.split(input, "\n", parts: 2)
    columns_filter(String.graphemes(l), [], 0, false)
  end

  def columns_filter([], acc, i, true), do: Enum.reverse([i | acc])
  def columns_filter([], acc, _i, false), do: Enum.reverse(acc)

  def columns_filter([" " | rest], acc, i, false) do
    columns_filter(rest, acc, i + 1, false)
  end

  def columns_filter([" " | rest], acc, i, true) do
    columns_filter(rest, [i | acc], i + 1, false)
  end

  def columns_filter([_nonspace | rest], acc, i, _) do
    columns_filter(rest, acc, i, true)
  end
end
