defmodule AdventOfCode.Solution.SharedParse do
  @moduledoc """
  Behaviour for solutions that share input parsing logic between parts 1 and 2.

  By `use`ing this module, a module adopts the behaviour and indicates to `mix
  advent.solve` that its `part1/1` and `part2/1` functions use the same value
  parsed from the puzzle input string, by a `parse/1` callback.

  `mix advent.solve` treats shared-parse solutions differently in the following
  ways:
  - If both parts are run, i.e., the `--part` option is omitted, then the input
    will be parsed once and the parsed value will be reused for both parts.
  - If the `--bench` option is used, then parsing will be benchmarked separately
    from the rest of the solution logic.
  """

  @doc """
  Parses the puzzle input.
  """
  @callback parse(input :: String.t()) :: term

  defmacro __using__(_) do
    quote do
      @behaviour AdventOfCode.Solution.SharedParse

      Module.register_attribute(__MODULE__, :__shared_parse__, persist: true)
      @__shared_parse__ true
    end
  end
end
