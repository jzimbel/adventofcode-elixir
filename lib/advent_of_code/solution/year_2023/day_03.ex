defmodule AdventOfCode.Solution.Year2023.Day03.Schematic do
  @type coords :: {non_neg_integer, non_neg_integer}
  @type t :: %__MODULE__{
          symbols: %{coords => char},
          digits: %{coords => reference},
          numbers: %{reference => non_neg_integer}
        }

  defstruct symbols: %{}, digits: %{}, numbers: %{}

  def from_input(input) do
    for {line, y} <- Enum.with_index(String.split(input, "\n", trim: true)),
        # Put an additional '.' at the end to make sure trailing digits get finalized as numbers
        line = line <> ".",
        {char, x} <- Enum.with_index(String.to_charlist(line)),
        reduce: %__MODULE__{} do
      # Non-symbol, completes a number
      {acc, start_coords, digits} when char == ?. ->
        finalize_number(acc, start_coords, digits)

      # Non-symbol
      acc when char == ?. ->
        acc

      # Digit, continues a number
      {acc, start_coords, digits} when char in ?0..?9 ->
        {acc, start_coords, [char - ?0 | digits]}

      # Digit, starts a new number
      acc when char in ?0..?9 ->
        {acc, {x, y}, [char - ?0]}

      # Symbol, completes a number
      {acc, start_coords, digits} ->
        acc
        |> finalize_number(start_coords, digits)
        |> then(&%{&1 | symbols: Map.put(&1.symbols, {x, y}, char)})

      # Symbol
      acc ->
        %{acc | symbols: Map.put(acc.symbols, {x, y}, char)}
    end

    # We know the acc will not end up in its {acc, start_coords, digits} alternate form
    # because the string will always end with '.', which will cause `finalize_number`
    # to be called even if the original input ends with a digit.
  end

  def symbol_adjacent_numbers(schematic) do
    # Get coords of all symbols
    schematic.symbols
    |> Map.keys()
    # Get all coords adjacent to those symbols
    |> Stream.flat_map(&adjacent_coords/1)
    # Get number refs for all those coords
    |> Stream.map(&schematic.digits[&1])
    # Remove duplicate refs
    |> Stream.uniq()
    # Remove nil
    |> Stream.reject(&is_nil/1)
    # Look up number for each ref
    |> Stream.map(&schematic.numbers[&1])
  end

  def gear_ratios(schematic) do
    # Get coords of all '*' symbols
    schematic.symbols
    |> Stream.flat_map(fn {coords, symbol} -> if symbol == ?*, do: [coords], else: [] end)
    # Get all coords adjacent to those symbols, keeping a separate list of adjacents per symbol
    |> Stream.map(&adjacent_coords/1)
    # Get number refs for each set of adjacent coords, filtering out duplicates & nil
    |> Stream.map(fn adjacents ->
      adjacents
      |> Stream.map(&schematic.digits[&1])
      |> Stream.uniq()
      |> Enum.reject(&is_nil/1)
    end)
    # Filter to those with exactly 2 adjacent number refs
    |> Stream.filter(&match?([_, _], &1))
    # Look up number for each ref and multiply each pair of numbers
    |> Stream.map(fn [ref1, ref2] -> schematic.numbers[ref1] * schematic.numbers[ref2] end)
  end

  # List of coords that produce the 8 coordinates surrounding a given coord when added to it
  @all_adjacent_deltas for x <- -1..1, y <- -1..1, not (x == 0 and y == 0), do: {x, y}

  defp adjacent_coords(coords) do
    Enum.map(@all_adjacent_deltas, &sum_coords(&1, coords))
  end

  defp sum_coords({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}

  defp finalize_number(acc, {x, y} = _start_coords, digits) do
    number = digits |> Enum.reverse() |> Integer.undigits()
    ref = make_ref()
    digit_positions = Map.new(0..(length(digits) - 1)//1, &{{x + &1, y}, ref})

    %{
      acc
      | digits: Map.merge(acc.digits, digit_positions),
        numbers: Map.put(acc.numbers, ref, number)
    }
  end
end

defmodule AdventOfCode.Solution.Year2023.Day03 do
  alias __MODULE__.Schematic

  use AdventOfCode.Solution.SharedParse

  @impl true
  defdelegate parse(input), to: Schematic, as: :from_input

  def part1(schematic) do
    schematic
    |> Schematic.symbol_adjacent_numbers()
    |> Enum.sum()
  end

  def part2(schematic) do
    schematic
    |> Schematic.gear_ratios()
    |> Enum.sum()
  end
end
