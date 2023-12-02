defmodule AdventOfCode.Solution.Year2023.Day02 do
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_game/1)
    |> Enum.filter(&valid_for_part1?/1)
    |> Enum.map(fn {game_id, _plays} -> game_id end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_game/1)
    |> Enum.map(&min_cube_power/1)
    |> Enum.sum()
  end

  @bag %{red: 12, green: 13, blue: 14}
  @default_play %{red: 0, green: 0, blue: 0}

  defp valid_for_part1?({_game_id, plays}) do
    Enum.all?(plays, &(&1.red <= @bag.red and &1.green <= @bag.green and &1.blue <= @bag.blue))
  end

  defp min_cube_power({_game_id, plays}) do
    plays
    |> Enum.reduce(@default_play, fn play, acc ->
      Map.merge(acc, play, fn _k, acc_val, play_val -> max(acc_val, play_val) end)
    end)
    |> Map.values()
    |> Enum.product()
  end

  @type parsed_game :: {pos_integer, list(play)}
  @type play :: %{red: non_neg_integer, green: non_neg_integer, blue: non_neg_integer}

  @spec parse_game(String.t()) :: parsed_game
  defp parse_game(line) do
    ["Game " <> game_id, plays] = String.split(line, ": ")

    game_id = String.to_integer(game_id)

    plays =
      plays
      |> String.split("; ")
      |> Enum.map(&parse_play/1)

    {game_id, plays}
  end

  defp parse_play(play) do
    counts =
      ~r/(\d+) (\w+)/
      |> Regex.scan(play, capture: :all_but_first)
      |> Map.new(fn [count, color] ->
        {String.to_existing_atom(color), String.to_integer(count)}
      end)

    Map.merge(@default_play, counts)
  end
end
