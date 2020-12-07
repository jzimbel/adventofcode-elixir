defmodule AdventOfCode.Day05 do
  def part1(args) do
    args
    |> get_seat_ids()
    |> Enum.max()
  end

  def part2(args) do
    args
    |> get_seat_ids()
    |> find_my_seat_id()
  end

  defp get_seat_ids(input) do
    input
    |> String.split()
    |> Enum.map(&String.split_at(&1, 7))
    |> Enum.map(fn {row, col} ->
      {parse_partition(row, &row_mapper/1), parse_partition(col, &col_mapper/1)}
    end)
    |> Enum.map(&seat_id/1)
  end

  defp row_mapper(?F), do: ?0
  defp row_mapper(?B), do: ?1

  defp col_mapper(?L), do: ?0
  defp col_mapper(?R), do: ?1

  defp parse_partition(partition, char_mapper) do
    partition
    |> String.to_charlist()
    |> Enum.map(char_mapper)
    |> List.to_string()
    |> String.to_integer(2)
  end

  defp seat_id({row_num, col_num}), do: row_num * 8 + col_num

  defp find_my_seat_id(seat_ids) do
    [first_id | rest] = Enum.sort(seat_ids)

    Enum.reduce_while(rest, first_id, fn seat_id, prev_seat_id ->
      if seat_id - prev_seat_id == 2 do
        {:halt, seat_id - 1}
      else
        {:cont, seat_id}
      end
    end)
  end
end
