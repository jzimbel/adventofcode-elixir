defmodule AdventOfCode.Solution.Year2021.Day14 do
  def part1(input) do
    measure_frequencies_at(input, 10)
  end

  def part2(input) do
    measure_frequencies_at(input, 40)
  end

  defp measure_frequencies_at(input, step) do
    {frequencies, rules, first_char, last_char} = parse_input(input)

    frequencies
    |> Stream.iterate(&insert(&1, rules))
    |> Enum.at(step)
    |> bigram_frequencies_to_unigram_frequencies(first_char, last_char)
    |> Map.values()
    |> Enum.min_max()
    |> then(fn {least_common_count, most_common_count} ->
      most_common_count - least_common_count
    end)
  end

  defp insert(freqs, rules) do
    update_keylist_and_merge_values(
      freqs,
      fn {[char_a, char_b] = chars, count} ->
        insertion = rules[chars]
        [{[char_a, insertion], count}, {[insertion, char_b], count}]
      end,
      &Enum.sum/1
    )
  end

  defp bigram_frequencies_to_unigram_frequencies(freqs, char, char) do
    do_bigram_frequencies_to_unigram_frequencies(freqs, fn
      {^char, doubled_freq} -> {char, ceil(doubled_freq / 2) + 1}
      {other_char, doubled_freq} -> {other_char, ceil(doubled_freq / 2)}
    end)
  end

  defp bigram_frequencies_to_unigram_frequencies(freqs, _, _) do
    do_bigram_frequencies_to_unigram_frequencies(freqs, fn
      {char, doubled_freq} -> {char, ceil(doubled_freq / 2)}
    end)
  end

  defp do_bigram_frequencies_to_unigram_frequencies(freqs, un_doubler) do
    freqs
    |> update_keylist_and_merge_values(
      fn {[char_a, char_b], freq} -> [{char_a, freq}, {char_b, freq}] end,
      &Enum.sum/1
    )
    |> Enum.into(%{}, un_doubler)
  end

  defp update_keylist_and_merge_values(keylist, updater, merger) do
    keylist
    |> Enum.flat_map(updater)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.map(fn {k, values} -> {k, merger.(values)} end)
  end

  defp parse_input(input) do
    [first_char | rest_chars] = String.to_charlist(input)
    last_char = List.last(rest_chars)

    input
    |> String.split("\n\n", trim: true)
    |> then(fn [polymer, rules] ->
      {bigram_frequencies(polymer), parse_rules(rules), first_char, last_char}
    end)
  end

  defp bigram_frequencies(string) do
    string
    |> String.to_charlist()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.frequencies()
  end

  defp parse_rules(rules) do
    rules
    |> String.split("\n", trim: true)
    |> Enum.map(fn <<char_a, char_b, " -> ", insertion>> -> {[char_a, char_b], insertion} end)
    |> Enum.into(%{})
  end
end
