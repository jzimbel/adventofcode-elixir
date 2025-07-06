defmodule AdventOfCode.Solution.Year2024.Day25 do
  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(fn grid ->
      case :binary.at(grid, 0) do
        ?# -> {:lock, hash_col_sizes(grid, &(&1..(&1 + 36)//6))}
        ?. -> {:key, hash_col_sizes(grid, &((&1 + 36)..&1//-6))}
      end
    end)
    |> Enum.group_by(fn {type, _} -> type end, fn {_, combo} -> combo end)
  end

  def part1(%{lock: locks, key: keys}) do
    for lock <- locks, key <- keys, reduce: 0 do
      count -> count + if(fit?(lock, key), do: 1, else: 0)
    end
  end

  def part2(_input) do
  end

  defp fit?(lock, key) do
    Stream.zip_with(lock, key, &Kernel.+/2)
    |> Enum.all?(&(&1 <= 7))
  end

  defp hash_col_sizes(grid, range_fn) do
    Enum.map(0..4, fn offset ->
      range_fn.(offset)
      |> Stream.take_while(&(:binary.at(grid, &1) == ?#))
      |> Enum.count()
    end)
  end
end
