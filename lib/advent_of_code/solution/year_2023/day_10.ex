defmodule AdventOfCode.Solution.Year2023.Day10 do
  alias AdventOfCode.CharGrid, as: G

  @enforce_keys [:coords, :heading]
  defstruct @enforce_keys

  def part1(input) do
    input
    |> G.from_input()
    |> s_loop_length()
    |> div(2)
  end

  def part2(_input) do
    # No thank u

    # ...
    # Count right/left turns?
    # More left: inside is anything to the left
    # More right: inside is anything to the right

    # 1. Count turns
    # 2. Record entire path as MapSet of coords
    # 3. Figure out which side is Inside
    # 4. Retrace path, looking on that side from each tile
    # 5. Find a tile that is not part of the path
    # 6. Count all adjacent tiles not part of the path

    # ^ Nope this doesn't work because inside tiles can be split into noncontiguous groups.
    # Need to scan row by row keeping track of even/odd number of path crossings, with extra logic for horizontal path overlaps
    # OR?
    # Keep a set of found Inside tiles while walking around the loop.
    # Each time you find a new Inside tile adjacent to the loop, check if it's in the found set. If not, flood fill and add all new Inside tiles to set.
    # Need to check all 3 adjacent tiles when rounding a corner away from Inside.
  end

  defp new(grid) do
    grid |> find_s() |> init_state(grid)
  end

  defp s_loop_length(grid) do
    grid
    |> new()
    |> Stream.iterate(&step(&1, grid))
    |> Stream.take_while(&(G.at(grid, &1.coords) != ?S))
    |> Enum.count()
    # The end state where we've returned to S is not included in the count,
    # So we need to add 1.
    |> Kernel.+(1)
  end

  defp step(state, grid), do: state |> move() |> turn(grid)

  defp move(state), do: %{state | coords: sum_coords(state.coords, move_delta(state.heading))}

  defp turn(state, grid) do
    %{state | heading: do_turn(G.at(grid, state.coords), state.heading)}
  end

  for char <- ~c"-|S" do
    defp do_turn(unquote(char), heading), do: heading
  end

  defp do_turn(pipe, heading) do
    case {pipe, heading} do
      {?7, :e} -> :s
      {?7, :n} -> :w
      {?F, :w} -> :s
      {?F, :n} -> :e
      {?L, :s} -> :e
      {?L, :w} -> :n
      {?J, :s} -> :w
      {?J, :e} -> :n
    end
  end

  for {heading, delta} <- [n: {0, -1}, e: {1, 0}, s: {0, 1}, w: {-1, 0}] do
    defp move_delta(unquote(heading)), do: unquote(delta)
  end

  defp find_s(grid) do
    [{s_coords, ?S}] = G.filter_cells(grid, &match?({_, ?S}, &1))
    s_coords
  end

  defp init_state(s_coords, grid) do
    grid
    |> G.adjacent_cells(s_coords, :cardinal)
    |> Enum.find_value(fn {coords, pipe} ->
      options =
        pipe
        |> pipe_headings()
        |> Enum.map(&%__MODULE__{coords: coords, heading: &1})

      case Enum.find_index(options, &(G.at(grid, move(&1).coords) == ?S)) do
        0 -> Enum.at(options, 1)
        1 -> Enum.at(options, 0)
        nil -> nil
      end
    end)
  end

  defp pipe_headings(pipe) do
    case pipe do
      ?| -> [:n, :s]
      ?- -> [:e, :w]
      ?7 -> [:s, :w]
      ?F -> [:s, :e]
      ?L -> [:n, :e]
      ?J -> [:n, :w]
      ?. -> []
    end
  end

  defp sum_coords({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}
end
