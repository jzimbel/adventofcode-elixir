defmodule AdventOfCode.Solution.Year2020.Day15 do
  def part1(args) do
    args
    |> parse_starting_numbers()
    |> stream_turns()
    |> Enum.at(2020)
    |> elem(1)
  end

  # (takes about 35 sec)
  def part2(args) do
    args
    |> parse_starting_numbers()
    |> stream_turns()
    |> Enum.at(30_000_000)
    |> elem(1)
  end

  defp parse_starting_numbers(input) do
    input
    |> String.trim_trailing()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp stream_turns(starting_numbers) do
    [last_number | starting_history] = Enum.reverse(starting_numbers)

    history =
      starting_history
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.into(%{})

    turn = map_size(history) + 2

    Stream.concat(
      starting_numbers,
      Stream.iterate({history, last_number, turn}, &next_turn/1)
    )
  end

  defp next_turn({history, last_number, turn}) do
    next_number =
      case Map.fetch(history, last_number) do
        {:ok, prev_turn} -> turn - 1 - prev_turn
        :error -> 0
      end

    {Map.put(history, last_number, turn - 1), next_number, turn + 1}
  end
end
