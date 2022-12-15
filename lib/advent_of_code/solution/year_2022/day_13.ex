defmodule AdventOfCode.Solution.Year2022.Day13 do
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_packet/1)
    |> Enum.chunk_every(2)
    |> Enum.with_index(1)
    |> Enum.filter(fn {[l, r], _i} -> in_order?(l, r) end)
    |> Enum.map(fn {_pair, i} -> i end)
    |> Enum.sum()
  end

  @divider_packets [[[2]], [[6]]]

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_packet/1)
    |> Enum.concat(@divider_packets)
    |> Enum.sort(&in_order?/2)
    |> Enum.with_index(1)
    |> Enum.filter(fn {packet, _i} -> packet in @divider_packets end)
    |> Enum.map(fn {_packet, i} -> i end)
    |> Enum.product()
  end

  defp parse_packet(line) do
    if Regex.match?(~r/^[\[\],\d]+$/, line),
      do: elem(Code.eval_string(line), 0),
      else: raise("I ain't eval-ing that")
  end

  # out of values to compare; should only occur in nested lists
  defp in_order?([], []), do: :tie

  # lists are different lengths and we've reached the end of one
  defp in_order?([], [_ | _]), do: true
  defp in_order?([_ | _], []), do: false

  # both values are integers
  defp in_order?([n | ltail], [n | rtail]) when is_integer(n), do: in_order?(ltail, rtail)
  defp in_order?([ln | _], [rn | _]) when is_integer(ln) and is_integer(rn), do: ln < rn

  # both values are lists
  defp in_order?([ll | ltail], [rl | rtail]) when is_list(ll) and is_list(rl) do
    case in_order?(ll, rl) do
      :tie -> in_order?(ltail, rtail)
      result -> result
    end
  end

  # one value is an integer
  defp in_order?([n | ltail], r) when is_integer(n), do: in_order?([[n] | ltail], r)
  defp in_order?(l, [n | rtail]) when is_integer(n), do: in_order?(l, [[n] | rtail])
end
