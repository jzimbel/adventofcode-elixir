defmodule AdventOfCode.Solution.Year2024.Day03 do
  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input), do: String.trim(input)

  def part1(mem) do
    ~r/mul\((\d{1,3}),(\d{1,3})\)/
    |> Regex.scan(mem, capture: :all_but_first)
    |> sum_of_products()
  end

  def part2(mem) do
    # (?| ...) drops unmatched alternatives from the returned captures.
    # E.g. matching "don't()" will produce ["don't()"] instead of ["", "", "", "don't()"]
    ~r"""
    (?|(mul)\((\d{1,3}),(\d{1,3})\)
      |(do)\(\)
      |(don't)\(\)
    )
    """x
    |> Regex.scan(mem, capture: :all_but_first)
    |> apply_toggles()
    |> sum_of_products()
  end

  defp sum_of_products(factor_pairs) do
    factor_pairs
    |> Enum.map(fn [a, b] -> String.to_integer(a) * String.to_integer(b) end)
    |> Enum.sum()
  end

  defp apply_toggles(matches) do
    Enum.reduce(matches, %{on?: true, acc: []}, fn
      ["mul" | factor_pair], state when state.on? -> update_in(state.acc, &[factor_pair | &1])
      ["mul" | _factor_pair], state when not state.on? -> state
      ["do"], state -> %{state | on?: true}
      ["don't"], state -> %{state | on?: false}
    end).acc
  end
end
