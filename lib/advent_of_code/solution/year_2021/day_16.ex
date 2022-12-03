defmodule AdventOfCode.Solution.Year2021.Day16 do
  def part1(input) do
    input
    |> parse()
    |> version_sum()
  end

  def part2(input) do
    input
    |> parse()
    |> eval()
  end

  defp parse(input) do
    input
    |> String.trim()
    |> hex_to_bitstring()
    |> do_parse()
    |> elem(0)
  end

  defp do_parse(packet, packets_remaining \\ 1, parsed \\ [])

  # base case for parsing a specific length of bits
  defp do_parse(<<>>, _, parsed) do
    {Enum.reverse(parsed), <<>>}
  end

  # base case for parsing a specific number of packets
  defp do_parse(rest, 0, parsed) do
    {Enum.reverse(parsed), rest}
  end

  # literal
  defp do_parse(<<version::3, 4::3, literal::bits>>, packets_remaining, parsed) do
    {n, rest} = parse_literal(literal)
    do_parse(rest, packets_remaining - 1, [{4, [n], version} | parsed])
  end

  # operator - total bit length
  defp do_parse(
         <<version::3, type::3, 0::1, len::15, packets::bits-size(len), rest::bits>>,
         packets_remaining,
         parsed
       ) do
    {args, <<>>} = do_parse(packets, -1)
    do_parse(rest, packets_remaining - 1, [{type, args, version} | parsed])
  end

  # operator - packet count
  defp do_parse(
         <<version::3, type::3, 1::1, sub_packet_count::11, sub_packets::bits>>,
         packets_remaining,
         parsed
       ) do
    {args, rest} = do_parse(sub_packets, sub_packet_count)
    do_parse(rest, packets_remaining - 1, [{type, args, version} | parsed])
  end

  defp parse_literal(literal, acc \\ [])

  defp parse_literal(<<0::1, last_part::4, rest::bits>>, acc) do
    literal_bits =
      [<<last_part::4>> | acc]
      |> Enum.reverse()
      |> :erlang.list_to_bitstring()

    n_size = bit_size(literal_bits)

    <<n::size(n_size)>> = literal_bits

    {n, rest}
  end

  defp parse_literal(<<1::1, n_part::4, rest::bits>>, acc) do
    parse_literal(rest, [<<n_part::4>> | acc])
  end

  defp get_op(0), do: fn args -> Enum.sum(Enum.map(args, &eval/1)) end
  defp get_op(1), do: fn args -> Enum.product(Enum.map(args, &eval/1)) end
  defp get_op(2), do: fn args -> Enum.min(Enum.map(args, &eval/1)) end
  defp get_op(3), do: fn args -> Enum.max(Enum.map(args, &eval/1)) end
  defp get_op(4), do: fn [arg] -> arg end
  defp get_op(5), do: fn [arg1, arg2] -> if(eval(arg1) > eval(arg2), do: 1, else: 0) end
  defp get_op(6), do: fn [arg1, arg2] -> if(eval(arg1) < eval(arg2), do: 1, else: 0) end
  defp get_op(7), do: fn [arg1, arg2] -> if(eval(arg1) == eval(arg2), do: 1, else: 0) end

  defp version_sum(parsed) do
    Enum.reduce(parsed, 0, fn
      {4, _, version}, acc -> acc + version
      {_op, nested, version}, acc -> acc + version + version_sum(nested)
    end)
  end

  defp eval([expr]), do: eval(expr)

  defp eval({type, args, _version}), do: get_op(type).(args)

  defp hex_to_bitstring(input, acc \\ [])

  defp hex_to_bitstring(<<>>, acc) do
    acc
    |> Enum.reverse()
    |> :erlang.list_to_bitstring()
  end

  defp hex_to_bitstring(<<hex_digit::bytes-size(1), rest::bytes>>, acc) do
    hex_to_bitstring(rest, [<<String.to_integer(hex_digit, 16)::4>> | acc])
  end
end
