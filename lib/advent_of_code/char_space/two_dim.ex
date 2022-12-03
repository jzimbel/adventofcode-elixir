defmodule AdventOfCode.CharSpace.TwoDim do
  @moduledoc "Data structure representing an infinite 2D grid of characters."

  defmodule Impl do
    @type coordinates :: {integer, integer, integer}

    @adjacent_deltas for x <- -1..1,
                         y <- -1..1,
                         not (x == 0 and y == 0),
                         do: {x, y}

    def new_coords(x, y), do: {x, y}

    def adjacent_deltas, do: @adjacent_deltas

    def all_coords({x_bounds, y_bounds}) do
      for x <- x_bounds, y <- y_bounds, do: {x, y}
    end

    def min_maxer({x, y}, {xmin..xmax, ymin..ymax}) do
      {min(x, xmin)..max(x, xmax), min(y, ymin)..max(y, ymax)}
    end

    def min_maxer({x2, y2}, {x1, y1}) do
      {min(x1, x2)..max(x1, x2), min(y1, y2)..max(y1, y2)}
    end

    def pad_ranges({x1..x2, y1..y2}) do
      {(x1 - 1)..(x2 + 1), (y1 - 1)..(y2 + 1)}
    end

    def sum_coordinates({x1, y1}, {x2, y2}) do
      {x1 + x2, y1 + y2}
    end
  end

  use AdventOfCode.CharSpace, dimensions_mod: Impl

  def to_string(%T{grid: grid, empty_char: empty_char}) do
    {x_bounds, y_bounds} = get_bounds(grid, empty_char)

    y_bounds
    |> Enum.map(fn y ->
      Enum.map(x_bounds, &grid[{&1, y}])
    end)
    |> Enum.join("\n")
  end
end

defimpl String.Chars, for: AdventOfCode.CharSpace.TwoDim do
  def to_string(space), do: AdventOfCode.CharSpace.TwoDim.to_string(space)
end
