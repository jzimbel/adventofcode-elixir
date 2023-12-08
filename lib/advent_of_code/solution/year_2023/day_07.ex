defmodule AdventOfCode.Solution.Year2023.Day07 do
  @type play :: {hand, bid :: pos_integer}
  @type hand :: list(pos_integer)

  @callback parse_card_value(char) :: pos_integer
  @callback top_2_groups(hand) :: list(pos_integer)

  def part1(input), do: solve(input, __MODULE__.Part1)
  def part2(input), do: solve(input, __MODULE__.Part2)

  def solve(input, impl) do
    input
    |> parse(impl)
    |> Enum.sort_by(fn {hand, _bid} -> {type_score(impl.top_2_groups(hand)), hand} end)
    |> Enum.with_index(fn {_hand, bid}, i -> bid * (i + 1) end)
    |> Enum.sum()
  end

  defp parse(input, impl) do
    for line <- String.split(input, "\n", trim: true), do: parse_play(line, impl)
  end

  defp parse_play(line, impl) do
    [hand, bid] = String.split(line)
    hand = for <<char <- hand>>, do: impl.parse_card_value(char)
    bid = String.to_integer(bid)

    {hand, bid}
  end

  for {groups, value} <- Enum.zip([[1, 1], [2, 1], [2, 2], [3, 1], [3, 2], [4, 1], [5]], 0..6) do
    defp type_score(unquote(groups)), do: unquote(value)
  end
end

defmodule AdventOfCode.Solution.Year2023.Day07.Part1 do
  @behaviour AdventOfCode.Solution.Year2023.Day07

  @impl true
  def top_2_groups(hand) do
    hand |> Enum.frequencies() |> Map.values() |> Enum.sort(:desc) |> Enum.take(2)
  end

  @impl true
  for {char, value} <- Enum.zip(~c[TJQKA], 10..14) do
    def parse_card_value(unquote(char)), do: unquote(value)
  end

  def parse_card_value(digit_char), do: digit_char - ?0
end

defmodule AdventOfCode.Solution.Year2023.Day07.Part2 do
  @behaviour AdventOfCode.Solution.Year2023.Day07

  @j_value 1

  @impl true
  def top_2_groups(hand) do
    {jokers, hand} = Enum.split_with(hand, &(&1 == @j_value))
    j_count = length(jokers)

    hand
    |> AdventOfCode.Solution.Year2023.Day07.Part1.top_2_groups()
    |> strengthen(j_count)
  end

  defp strengthen([], 5), do: [5]
  defp strengthen([top | rest], j_count), do: [top + j_count | rest]

  @impl true
  def parse_card_value(?T), do: 10
  def parse_card_value(?J), do: @j_value

  for {char, value} <- Enum.zip(~c[QKA], 12..14) do
    def parse_card_value(unquote(char)), do: unquote(value)
  end

  def parse_card_value(digit_char), do: digit_char - ?0
end
