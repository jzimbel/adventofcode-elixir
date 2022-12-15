defmodule AdventOfCode.Solution.Year2022.Day10 do
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.transform(1, &parse_cycles/2)
    |> Stream.drop(19)
    |> Stream.take_every(40)
    |> Stream.take(6)
    |> Enum.with_index(fn v, i -> (20 + 40 * i) * v end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.transform(1, &parse_cycles/2)
    |> Stream.zip(Stream.cycle(0..39))
    |> Stream.map(fn
      {signal, draw} when abs(draw - signal) <= 1 -> ?▓
      _ -> ?░
    end)
    |> Stream.chunk_every(40)
    |> Enum.intersperse(?\n)
    |> to_string()
  end

  defp parse_cycles("noop", v), do: {[v], v}
  defp parse_cycles(<<"addx ", n::binary>>, v), do: {[v, v], v + String.to_integer(n)}
end
