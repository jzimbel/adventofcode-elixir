defmodule AdventOfCode.Solution.Year2023.Day02.Play do
  @type t :: %__MODULE__{red: non_neg_integer, green: non_neg_integer, blue: non_neg_integer}
  defstruct red: 0, green: 0, blue: 0

  def compare(p1, p2) do
    cond do
      p1 == p2 -> :eq
      p1.red > p2.red or p1.green > p2.green or p1.blue > p2.blue -> :gt
      true -> :lt
    end
  end

  def merge(p1, p2) do
    %__MODULE__{
      red: max(p1.red, p2.red),
      green: max(p1.green, p2.green),
      blue: max(p1.blue, p2.blue)
    }
  end
end

defmodule AdventOfCode.Solution.Year2023.Day02 do
  alias __MODULE__.Play

  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_game/1)
  end

  def part1(games) do
    games
    |> Stream.filter(&valid_for_part1?/1)
    |> Stream.map(fn {game_id, _plays} -> game_id end)
    |> Enum.sum()
  end

  def part2(games) do
    games
    |> Stream.map(&min_cube_power/1)
    |> Enum.sum()
  end

  @bag %Play{red: 12, green: 13, blue: 14}

  defp valid_for_part1?({_game_id, plays}) do
    Enum.all?(plays, &(Play.compare(&1, @bag) in [:lt, :eq]))
  end

  defp min_cube_power({_game_id, plays}) do
    plays
    |> Enum.reduce(&Play.merge/2)
    |> Map.from_struct()
    |> Map.values()
    |> Enum.product()
  end

  @spec parse_game(String.t()) :: {pos_integer, list(Play.t())}
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
    ~r/(\d+) (\w+)/
    |> Regex.scan(play, capture: :all_but_first)
    |> Map.new(fn [count, color] ->
      {String.to_existing_atom(color), String.to_integer(count)}
    end)
    |> then(&struct(Play, &1))
  end
end
