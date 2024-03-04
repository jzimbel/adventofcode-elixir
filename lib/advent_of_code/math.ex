defmodule AdventOfCode.Math do
  @moduledoc """
  Common math functions/algorithms.
  """

  @doc """
  Greatest common denominator.
  """
  @spec gcd(Enumerable.t(pos_integer)) :: pos_integer
  def gcd(ns), do: Enum.reduce(ns, &gcd/2)

  defp gcd(d, 0), do: d
  defp gcd(a, b), do: gcd(b, Integer.mod(a, b))

  @doc """
  Least common multiple.
  """
  @spec lcm(Enumerable.t(pos_integer)) :: pos_integer
  def lcm(ns), do: Enum.reduce(ns, &lcm/2)

  defp lcm(a, b), do: div(a * b, gcd(a, b))

  @doc """
  Returns true if n is a power of 2.

  From https://stackoverflow.com/a/57025941:
  > Every power of 2 has exactly 1 bit set to 1 (the bit in that number's log base-2 index).
  > So when subtracting 1 from it, that bit flips to 0 and all preceding bits flip to 1.
  > That makes these 2 numbers the inverse of each other so when AND-ing them, we will get 0 as the result.
  """
  @spec pow2?(non_neg_integer) :: boolean
  def pow2?(0), do: false
  def pow2?(n) when n > 0, do: Bitwise.band(n, n - 1) == 0
end
