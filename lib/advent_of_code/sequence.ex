defmodule AdventOfCode.Sequence do
  @moduledoc """
  Functions for infinitely repeating sequences.
  """

  @doc """
  Given an indexed list describing the repeating segment of an infinitely repeating sequence,
  returns the value at `at_index` of the sequence.

  Indices in the list do not need to start at 0, but they do need to be contiguous,
  and the list must be ordered by index, ascending.

  `at_index` can be any integer.
  """
  @spec at(nonempty_list({a, index :: integer}), integer) :: a when a: term
  def at(repeat, i) do
    [{_value, start_index} | _] = repeat
    {value, _index} = Enum.at(repeat, Integer.mod(i - start_index, length(repeat)))
    value
  end
end
