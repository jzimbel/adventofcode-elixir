defmodule AdventOfCode.Day12 do
  defmodule Ship do
    defstruct posn: {0, 0},
              heading: {1, 0}

    def navigate(%Ship{} = t, []), do: t

    def navigate(%Ship{} = t, [action | actions]) do
      t
      |> do_action(action)
      |> navigate(actions)
    end

    defp do_action(t, action_string)

    for {dir, norm_vec} <- %{?N => {0, -1}, ?E => {1, 0}, ?S => {0, 1}, ?W => {-1, 0}} do
      defp do_action(t, <<unquote(dir), mag::binary>>) do
        %{t | posn: translate(t.posn, unquote(norm_vec), String.to_integer(mag))}
      end
    end

    for {dir, sign} <- %{?L => 1, ?R => -1} do
      defp do_action(t, <<unquote(dir), deg::binary>>) do
        %{t | heading: rotate(t.heading, String.to_integer(deg), rotater_for(unquote(sign)))}
      end
    end

    defp do_action(t, <<?F, mag::binary>>) do
      %{t | posn: translate(t.posn, t.heading, String.to_integer(mag))}
    end

    defp translate({x, y}, {dx, dy}, mag) do
      {x + mag * dx, y + mag * dy}
    end

    defp rotate(heading, 0, _), do: heading
    defp rotate(heading, deg, rotater), do: rotate(rotater.(heading), deg - 90, rotater)

    # Given a direction sign (1 for counterclockwise, -1 for clockwise), produces a
    # function that rotates a heading by 90 degrees in that direction.
    defp rotater_for(sign), do: fn {x, y} -> {sign * y, -sign * x} end
  end

  def part1(args) do
    ship = Ship.navigate(%Ship{}, String.split(args))

    manhattan({0, 0}, ship.posn)
  end

  def part2(_args) do
    nil
  end

  defp manhattan({x1, y1}, {x2, y2}), do: abs(x2 - x1) + abs(y2 - y1)
end
