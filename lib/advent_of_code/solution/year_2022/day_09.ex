defmodule AdventOfCode.Solution.Year2022.Day09 do
  defstruct [:knots, visited: MapSet.new([{0, 0}])]

  def part1(input), do: solve(input, 2)
  def part2(input), do: solve(input, 10)

  defp solve(input, knot_count) do
    initial_state = %__MODULE__{knots: List.duplicate({0, 0}, knot_count)}

    final_state =
      input
      |> String.split("\n", trim: true)
      |> Enum.reduce(initial_state, &process_command/2)

    MapSet.size(final_state.visited)
  end

  for {dir, delta} <- [{?U, {0, -1}}, {?R, {1, 0}}, {?D, {0, 1}}, {?L, {-1, 0}}] do
    defp process_command(<<unquote(dir), " ", steps::binary>>, state) do
      for _ <- 1..String.to_integer(steps), reduce: state, do: (acc -> move(acc, unquote(delta)))
    end
  end

  defp move(%__MODULE__{knots: [h | t], visited: visited}, delta) do
    knots = Enum.scan([add(h, delta) | t], &propagate/2)
    visited = MapSet.put(visited, List.last(knots))

    %__MODULE__{knots: knots, visited: visited}
  end

  defp propagate(t, h), do: if(adjacent?(h, t), do: t, else: move_toward(t, h))

  defp adjacent?({x, y}, {x2, y2}), do: abs(x2 - x) <= 1 and abs(y2 - y) <= 1

  defp move_toward({tx, ty}, {hx, hy}), do: add({tx, ty}, {get_move(hx - tx), get_move(hy - ty)})

  defp get_move(0), do: 0
  defp get_move(diff), do: div(diff, abs(diff))

  defp add({x, y}, {x2, y2}), do: {x + x2, y + y2}
end
