defmodule AdventOfCode.Solution.Year2021.Day04 do
  alias __MODULE__.BingoPlayer

  def part1(input) do
    {draws, boards} = parse_input(input)

    players =
      boards
      |> Enum.map(&BingoPlayer.start_link/1)
      |> Enum.map(fn {:ok, pid} -> pid end)

    get_first_winner_score(draws, players)
  end

  def part2(input) do
    {draws, boards} = parse_input(input)

    players =
      boards
      |> Enum.map(&BingoPlayer.start_link/1)
      |> Enum.map(fn {:ok, pid} -> pid end)

    get_last_winner_score(draws, players)
  end

  defp get_first_winner_score([draw | draws], players) do
    Enum.each(players, &BingoPlayer.call_draw(&1, draw))

    players
    |> Enum.find(&BingoPlayer.bingo?/1)
    |> case do
      nil -> get_first_winner_score(draws, players)
      player -> BingoPlayer.score(player, draw)
    end
  end

  defp get_last_winner_score([draw | draws], players) do
    Enum.each(players, &BingoPlayer.call_draw(&1, draw))

    if Enum.all?(players, &BingoPlayer.bingo?/1) do
      players
      |> List.last()
      |> BingoPlayer.score(draw)
    else
      get_last_winner_score(draws, Enum.reject(players, &BingoPlayer.bingo?/1))
    end
  end

  defp parse_input(input) do
    [draws | boards] = String.split(input, "\n\n", trim: true)

    {parse_draws(draws), Enum.map(boards, &parse_board/1)}
  end

  defp parse_draws(draws) do
    draws
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_board(board) do
    for {line, y} <- board |> String.split("\n") |> Enum.with_index(),
        {num, x} <- line |> String.split(" ", trim: true) |> Enum.with_index(),
        into: %{},
        do: {{x, y}, {String.to_integer(num), false}}
  end
end

defmodule AdventOfCode.Solution.Year2021.Day04.BingoPlayer do
  use Agent

  def start_link(initial_board) do
    Agent.start_link(fn -> initial_board end)
  end

  def call_draw(pid, draw) do
    Agent.update(pid, &do_call_draw(&1, draw))
  end

  def bingo?(pid) do
    Agent.get(pid, &do_bingo?/1)
  end

  def score(pid, last_draw) do
    Agent.get(pid, &do_score(&1, last_draw))
  end

  defp do_call_draw(board, draw) do
    Enum.into(board, %{}, fn
      {k, {^draw, _}} -> {k, {draw, true}}
      entry -> entry
    end)
  end

  defp do_bingo?(board) do
    row_column_coord_lists()
    |> Stream.map(fn coords -> Enum.map(coords, fn coord -> board[coord] |> elem(1) end) end)
    |> Enum.any?(&Enum.all?/1)
  end

  defp row_column_coord_lists do
    columns = fn x -> Enum.map(0..4, &{x, &1}) end
    rows = fn y -> Enum.map(0..4, &{&1, y}) end

    Stream.map(0..4, columns) |> Stream.concat(Stream.map(0..4, rows))
  end

  defp do_score(board, last_draw) do
    board
    |> Map.values()
    |> Enum.reject(fn {_n, marked} -> marked end)
    |> Enum.map(fn {n, _marked} -> n end)
    |> Enum.sum()
    |> Kernel.*(last_draw)
  end
end
