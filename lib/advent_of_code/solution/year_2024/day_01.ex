defmodule AdventOfCode.Solution.Year2024.Day01 do
  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> then(
      &[
        _col_a = Enum.take_every(&1, 2),
        _col_b = Enum.take_every(tl(&1), 2)
      ]
    )
  end

  def part1(cols) do
    cols
    |> Enum.map(&Enum.sort/1)
    |> Enum.zip()
    |> Enum.map(fn {a, b} -> abs(a - b) end)
    |> Enum.sum()
  end

  def part2([col_a, col_b]) do
    a_freq = Enum.frequencies(col_a)
    b_freq = Enum.frequencies(col_b)

    a_freq
    |> Enum.map(fn {n, freq} -> n * freq * Map.get(b_freq, n, 0) end)
    |> Enum.sum()
  end
end
