defmodule AdventOfCode.Solution.SharedParse do
  @moduledoc """
  By `use`ing this module, a module adopts the behaviour and
  indicates to `advent.solve` that its `part1/1` and `part2/1` functions use the same value
  parsed from the puzzle input string.

  `advent.solve` treats shared-parse solutions differently in the following ways:
  - If both parts are run, i.e., the `--part` option is omitted, then the input will be parsed once
    and the parsed value will be reused for both parts.
  - If the `--bench` option is used, then parsing will be benchmarked separately
  from the rest of the solution logic.
  """

  defmacro __using__(_) do
    quote do
      @behaviour AdventOfCode.Solution.SharedParse

      Module.register_attribute(__MODULE__, :__shared_parse__, persist: true)
      @__shared_parse__ true
    end
  end

  @callback parse(input :: String.t()) :: term
end
