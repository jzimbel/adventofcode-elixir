defmodule AdventOfCode.Solution.Year2021.Day08 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(fn {_signal_char_sets, output_char_sets} ->
      Enum.count(output_char_sets, &is_1_4_7_or_8?/1)
    end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&get_output_value/1)
    |> Enum.sum()
  end

  defp is_1_4_7_or_8?(char_set) do
    MapSet.size(char_set) in [2, 4, 3, 7]
  end

  defp get_output_value({signal_char_sets, output_char_sets}) do
    char_set_to_int = get_char_set_to_int(signal_char_sets)

    output_char_sets
    |> Enum.map(&char_set_to_int[&1])
    |> Integer.undigits()
  end

  defp get_char_set_to_int(signal_char_sets) do
    one = Enum.find(signal_char_sets, &(MapSet.size(&1) == 2))
    four = Enum.find(signal_char_sets, &(MapSet.size(&1) == 4))

    decoded_signals = Enum.map(signal_char_sets, &decode_signal(&1, one, four))

    Enum.into(Enum.zip(signal_char_sets, decoded_signals), %{})
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    ~r/([^|]+) \| ([^|]+)/
    |> Regex.run(line, capture: :all_but_first)
    |> Enum.map(&string_to_char_sets/1)
    |> List.to_tuple()
  end

  defp string_to_char_sets(string) do
    string
    |> String.split()
    |> Enum.map(&for <<char <- &1>>, into: MapSet.new(), do: char)
  end

  defp decode_signal(signal, one, four) do
    import MapSet, only: [intersection: 2, size: 1]

    case {size(signal), size(intersection(signal, one)), size(intersection(signal, four))} do
      {6, 2, 3} -> 0
      {2, _, _} -> 1
      {5, 1, 2} -> 2
      {5, 2, 3} -> 3
      {4, _, _} -> 4
      {5, 1, 3} -> 5
      {6, 1, 3} -> 6
      {3, _, _} -> 7
      {7, _, _} -> 8
      {6, _, 4} -> 9
    end
  end
end
