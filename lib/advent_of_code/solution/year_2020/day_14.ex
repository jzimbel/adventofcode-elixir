defmodule AdventOfCode.Solution.Year2020.Day14 do
  def part1(args) do
    solve(args, fn input -> parse_input(input, &parse_mask_p1/1) end, &run_p1/2)
  end

  def part2(args) do
    solve(args, fn input -> parse_input(input, &parse_mask_p2/1) end, &run_p2/2)
  end

  defp solve(input, parser, runner) do
    input
    |> parser.()
    |> Enum.reduce({nil, %{}}, runner)
    |> elem(1)
    |> Map.values()
    |> Enum.sum()
  end

  defp run_p1({:mask, mask}, {_, mem}) do
    {mask, mem}
  end

  defp run_p1({:mem, address, value}, {mask, mem}) do
    mem = Map.put(mem, address, apply_mask_p1(mask, int_to_36_bits(value)))

    {mask, mem}
  end

  defp run_p2({:mem, address, value}, {mask, mem}) do
    mem =
      for address <- apply_mask_p2(mask, int_to_36_bits(address)),
          into: mem,
          do: {address, value}

    {mask, mem}
  end

  defp run_p2(instruction, acc), do: run_p1(instruction, acc)

  defp parse_input(input, mask_parser) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line(&1, mask_parser))
  end

  defp parse_line("mask = " <> mask, mask_parser) do
    {:mask, mask_parser.(mask)}
  end

  defp parse_line(mem_line, _) do
    [address, value] = Regex.run(~r|mem\[(\d+)\] = (\d+)|, mem_line, capture: :all_but_first)

    {:mem, String.to_integer(address), String.to_integer(value)}
  end

  defp parse_mask_p1(mask) do
    mask
    |> String.to_charlist()
    |> Enum.map(fn
      ?X -> &Function.identity/1
      ?0 -> fn _ -> 0 end
      ?1 -> fn _ -> 1 end
    end)
  end

  defp parse_mask_p2(mask) do
    mask
    |> String.to_charlist()
    |> Enum.reduce([[]], fn
      ?0, masks ->
        Enum.map(masks, fn mask -> [(&Function.identity/1) | mask] end)

      ?1, masks ->
        Enum.map(masks, fn mask -> [fn _ -> 1 end | mask] end)

      ?X, masks ->
        Enum.flat_map(masks, fn mask -> [[fn _ -> 0 end | mask], [fn _ -> 1 end | mask]] end)
    end)
    |> Enum.map(&Enum.reverse/1)
  end

  defp apply_mask_p1(mask, bits) do
    bits
    |> Enum.zip(mask)
    |> Enum.map(fn {digit, masker} -> masker.(digit) end)
    |> Integer.undigits(2)
  end

  defp apply_mask_p2(mask, bits) do
    Enum.map(mask, &apply_mask_p1(&1, bits))
  end

  defp int_to_36_bits(value) do
    value
    |> Integer.to_string(2)
    |> String.pad_leading(36, "0")
    |> String.to_charlist()
    # ?0 - 48 == 0
    |> Enum.map(&(&1 - 48))
  end
end
