defmodule AdventOfCode.CharSpace.ThreeDim do
  @moduledoc "Data structure representing an infinite 3D grid of characters."

  defmodule Impl do
    @type coordinates :: {integer, integer, integer}

    @adjacent_deltas for x <- -1..1,
                         y <- -1..1,
                         z <- -1..1,
                         not (x == 0 and y == 0 and z == 0),
                         do: {x, y, z}

    def new_coords(x, y), do: {x, y, 0}

    def adjacent_deltas, do: @adjacent_deltas

    def all_coords({x_bounds, y_bounds, z_bounds}) do
      for x <- x_bounds, y <- y_bounds, z <- z_bounds, do: {x, y, z}
    end

    def min_maxer({x, y, z}, {xmin..xmax, ymin..ymax, zmin..zmax}) do
      {min(x, xmin)..max(x, xmax), min(y, ymin)..max(y, ymax), min(z, zmin)..max(z, zmax)}
    end

    def min_maxer({x2, y2, z2}, {x1, y1, z1}) do
      {min(x1, x2)..max(x1, x2), min(y1, y2)..max(y1, y2), min(z1, z2)..max(z1, z2)}
    end

    def pad_ranges({x1..x2, y1..y2, z1..z2}) do
      {(x1 - 1)..(x2 + 1), (y1 - 1)..(y2 + 1), (z1 - 1)..(z2 + 1)}
    end

    def sum_coordinates({x1, y1, z1}, {x2, y2, z2}) do
      {x1 + x2, y1 + y2, z1 + z2}
    end
  end

  use AdventOfCode.CharSpace, dimensions_mod: Impl
end
