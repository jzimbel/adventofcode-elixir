defmodule AdventOfCode.Point do
  @moduledoc """
  Functions for manipulating integer-valued points on an image plane,
  where +x == east/right and +y == south/down.
  """

  @origin {0, 0}

  @type t :: {integer(), integer()}

  @type direction :: ?N | ?E | ?S | ?W
  @type rot_direction :: ?L | ?R

  defguardp is_cardinal(deg) when rem(deg, 90) == 0

  @doc """
  Translates `pt` by `dir`, `mag` times.

  `dir` can be either an `{x, y}` pair,
  or one of `?N` `?E` `?S` `?W`; each representing a unit vector in that direction.
  """
  @spec translate(t(), t() | direction, integer()) :: t()
  def translate(pt, dir, mag \\ 1)

  def translate({x, y}, {dx, dy}, mag) do
    {x + mag * dx, y + mag * dy}
  end

  for {dir, unit_vec} <- %{?N => {0, -1}, ?E => {1, 0}, ?S => {0, 1}, ?W => {-1, 0}} do
    def translate(pt, unquote(dir), mag) do
      translate(pt, unquote(unit_vec), mag)
    end
  end

  @doc """
  Rotates `pt` about `center` by `deg` degrees, in the direction of `dir`.

  `deg` must be a multiple of 90.

  A `dir` value of `?L` or 1 represents counterclockwise rotation; `?R` or -1 clockwise.

  `center` can be omitted to perform a rotation about the origin.
  """
  @spec rotate(t(), t(), non_neg_integer, -1 | 1 | rot_direction) :: t()
  def rotate(pt, center \\ @origin, deg, rot_dir)

  def rotate(pt, _, 0, _), do: pt

  def rotate(pt, @origin, deg, rot_dir) when is_cardinal(deg) do
    do_rotate(pt, deg, rotater_for(rot_dir))
  end

  def rotate(pt, {cx, cy}, deg, rot_dir) when is_cardinal(deg) do
    pt
    |> translate({-cx, -cy})
    |> rotate(deg, rot_dir)
    |> translate({cx, cy})
  end

  defp do_rotate(pt, 0, _), do: pt

  defp do_rotate(pt, deg, rotater), do: do_rotate(rotater.(pt), deg - 90, rotater)

  defp rotater_for(?L), do: rotater_for(1)
  defp rotater_for(?R), do: rotater_for(-1)
  defp rotater_for(sign), do: fn {x, y} -> {sign * y, -sign * x} end
end
