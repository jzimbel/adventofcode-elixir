defmodule AdventOfCode.Math do
  @moduledoc """
  Common math functions/algorithms.
  """

  @doc """
  Greatest common denominator.
  """
  @spec gcd(Enumerable.t(pos_integer)) :: pos_integer()
  def gcd(ns), do: Enum.reduce(ns, &gcd/2)

  defp gcd(d, 0), do: d
  defp gcd(a, b), do: gcd(b, Integer.mod(a, b))

  @doc """
  Least common multiple.
  """
  @spec lcm(Enumerable.t(pos_integer)) :: pos_integer()
  def lcm(ns), do: Enum.reduce(ns, &lcm/2)

  defp lcm(a, b), do: div(a * b, gcd(a, b))
end
