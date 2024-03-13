defmodule AdventOfCode.Solution.Year2023.Day04 do
  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_card/1)
  end

  def part1(cards) do
    cards
    |> Enum.map(&score_card/1)
    |> Enum.sum()
  end

  def part2(cards), do: count_cards(cards)

  defp score_card({_, 0}), do: 0
  defp score_card({_, n}), do: Integer.pow(2, n - 1)

  defp count_cards(cards, acc \\ 0)
  defp count_cards([], acc), do: acc

  defp count_cards([{self_copy_count, 0} | children], acc) do
    count_cards(children, acc + self_copy_count)
  end

  defp count_cards([{self_copy_count, child_copy_count} | children], acc) do
    {children_to_copy, unchanged} = Enum.split(children, child_copy_count)

    new_children =
      for {sub_self_copy_count, sub_child_copy_count} <- children_to_copy do
        {sub_self_copy_count + self_copy_count, sub_child_copy_count}
      end

    count_cards(new_children ++ unchanged, acc + self_copy_count)
  end

  defp parse_card(line) do
    [_card_number, contents] = String.split(line, ": ")

    [winners_str, hand_str] = String.split(contents, " | ")
    winners = MapSet.new(String.split(winners_str))
    hand = MapSet.new(String.split(hand_str))

    {1, MapSet.size(MapSet.intersection(winners, hand))}
  end
end
