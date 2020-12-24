defmodule AdventOfCode.CharSpace.FourDim do
  @moduledoc "Data structure representing an infinite 4D grid of characters."

  defmodule Impl do
    @type coordinates :: {integer, integer, integer, integer}

    @adjacent_deltas for x <- -1..1,
                         y <- -1..1,
                         z <- -1..1,
                         w <- -1..1,
                         not (x == 0 and y == 0 and z == 0 and w == 0),
                         do: {x, y, z, w}

    def new_coords(x, y), do: {x, y, 0, 0}

    def adjacent_deltas, do: @adjacent_deltas

    def all_coords({x_bounds, y_bounds, z_bounds, w_bounds}) do
      for x <- x_bounds, y <- y_bounds, z <- z_bounds, w <- w_bounds, do: {x, y, z, w}
    end

    def min_maxer({x, y, z, w}, {xmin..xmax, ymin..ymax, zmin..zmax, wmin..wmax}) do
      {min(x, xmin)..max(x, xmax), min(y, ymin)..max(y, ymax), min(z, zmin)..max(z, zmax),
       min(w, wmin)..max(w, wmax)}
    end

    def min_maxer({x2, y2, z2, w2}, {x1, y1, z1, w1}) do
      {min(x1, x2)..max(x1, x2), min(y1, y2)..max(y1, y2), min(z1, z2)..max(z1, z2),
       min(w1, w2)..max(w1, w2)}
    end

    def pad_ranges({x1..x2, y1..y2, z1..z2, w1..w2}) do
      {(x1 - 1)..(x2 + 1), (y1 - 1)..(y2 + 1), (z1 - 1)..(z2 + 1), (w1 - 1)..(w2 + 1)}
    end

    def sum_coordinates({x1, y1, z1, w1}, {x2, y2, z2, w2}) do
      {x1 + x2, y1 + y2, z1 + z2, w1 + w2}
    end
  end

  use AdventOfCode.CharSpace, dimensions_mod: Impl
end
