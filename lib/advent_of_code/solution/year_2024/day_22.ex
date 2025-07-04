defmodule AdventOfCode.Solution.Year2024.Day22 do
  import Bitwise

  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input) do
    Enum.map(String.split(input, "\n", trim: true), &String.to_integer/1)
  end

  def part1(seeds) do
    seeds |> Stream.map(&Enum.at(secrets(&1), 2000)) |> Enum.sum()
  end

  def part2(seeds) do
    seeds
    |> Stream.map(&prices_by_change_seq/1)
    |> Enum.reduce(fn map, acc ->
      Map.merge(acc, map, fn _change_seq, prices, [price] -> [price | prices] end)
    end)
    |> Stream.map(fn {_change_seq, prices} -> Enum.sum(prices) end)
    |> Enum.max()
  end

  defp secrets(seed), do: Stream.iterate(seed, &next_secret/1) |> Stream.take(2001)

  defp prices_by_change_seq(seed) do
    seed
    |> secrets()
    |> Stream.map(&rem(&1, 10))
    |> Stream.chunk_every(2, 1, :discard)
    |> Stream.map(fn [prev_price, price] -> {price - prev_price, price} end)
    |> Stream.chunk_every(4, 1, :discard)
    |> Stream.map(fn [{δ1, _}, {δ2, _}, {δ3, _}, {δ4, price}] ->
      # Wrap price in a list to prepare for merging with the other %{seq => price} maps.
      {[δ1, δ2, δ3, δ4], [price]}
    end)
    # Only the first of each duplicate change seq matters
    |> Stream.uniq_by(fn {change_seq, _price} -> change_seq end)
    |> Map.new()
  end

  defp next_secret(secret), do: Enum.reduce([6, -5, 11], secret, &mix_prune/2)
  defp mix_prune(shift, n), do: n |> bsl(shift) |> bxor(n) |> band(16_777_216 - 1)
end
