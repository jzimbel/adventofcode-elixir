defmodule AdventOfCode.Solution.Year2024.Day02 do
  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input) do
    for line <- String.split(input, "\n", trim: true) do
      line |> String.split() |> Enum.map(&String.to_integer/1)
    end
  end

  def part1(reports), do: Enum.count(reports, &safe_p1?/1)
  def part2(reports), do: Enum.count(reports, &safe_p2?/1)

  defp safe_p1?(ns) do
    ns
    |> Enum.chunk_every(2, 1, :discard)
    |> Stream.scan(nil, &check_interval/2)
    |> Enum.all?(&(&1 != :not_safe))
  end

  defp check_interval([a, b], asc?) do
    with true <- gradual?(a, b),
         {:ok, asc?} <- asc_desc?(a, b, asc?) do
      asc?
    else
      false -> :not_safe
    end
  end

  defp gradual?(a, b), do: abs(b - a) in 1..3

  defp asc_desc?(a, b, nil), do: {:ok, b - a > 0}
  defp asc_desc?(a, b, asc?) when asc? == b - a > 0, do: {:ok, asc?}
  defp asc_desc?(_a, _b, _asc?), do: false

  # Brute-force runs in a few hundred µs so I guess it's fine!
  defp safe_p2?(ns) do
    safe_p1?(ns) or
      Enum.any?(
        0..(length(ns) - 1),
        &safe_p1?(List.delete_at(ns, &1))
      )
  end
end
