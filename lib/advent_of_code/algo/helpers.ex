defmodule AdventOfCode.Algo.Helpers do
  @moduledoc false

  def manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end
end
