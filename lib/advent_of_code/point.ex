defmodule AdventOfCode.Point do
  @moduledoc """
  Functions for manipulating integer-valued points on an image plane,
  where +x == east/right and +y == south/down.
  """

  @origin {0, 0}

  @type t :: {integer(), integer()}

  @doc "Translates `pt` by `dir`, `mag` times."
  @spec translate(t(), t(), integer()) :: t()
  def translate(pt, dir, mag \\ 1)

  def translate({x, y}, {dx, dy}, mag) do
    {x + mag * dx, y + mag * dy}
  end

  @doc """
  Rotates `pt` about `center` by `deg` degrees, in the direction of `sign`.

  `deg` must be a multiple of 90.

  A `sign` value of 1 represents counterclockwise rotation; -1 clockwise.

  `center` can be omitted to perform a rotation about the origin.
  """
  @spec rotate(t(), t(), non_neg_integer, -1 | 1) :: t()
  def rotate(pt, center \\ @origin, deg, sign)

  def rotate(pt, _, 0, _), do: pt

  def rotate(pt, @origin, deg, sign), do: do_rotate(pt, deg, rotater_for(sign))

  def rotate(pt, {cx, cy}, deg, sign) when rem(deg, 90) == 0 do
    pt
    |> translate({-cx, -cy})
    |> rotate(deg, sign)
    |> translate({cx, cy})
  end

  defp do_rotate(pt, 0, _), do: pt

  defp do_rotate(pt, deg, rotater), do: do_rotate(rotater.(pt), deg - 90, rotater)

  # Given a direction sign (1 for counterclockwise, -1 for clockwise), produces a
  # function that rotates a point by 90 degrees in that direction about the origin.
  defp rotater_for(sign), do: fn {x, y} -> {sign * y, -sign * x} end
end
