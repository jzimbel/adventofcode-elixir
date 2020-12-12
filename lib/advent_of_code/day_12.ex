defmodule AdventOfCode.Day12 do
  defmodule Point do
    @type t :: {integer(), integer()}

    @spec translate(t(), t(), integer()) :: t()
    def translate({x, y}, {dx, dy}, mag \\ 1) do
      {x + mag * dx, y + mag * dy}
    end

    @spec rotate(t(), t(), non_neg_integer, -1 | 1) :: t()
    def rotate(pt, center, deg, sign)

    def rotate(pt, _, 0, _), do: pt

    def rotate(pt, {0, 0}, deg, sign), do: do_rotate(pt, deg, rotater_for(sign))

    def rotate(pt, {cx, cy}, deg, sign) when rem(deg, 90) == 0 do
      pt
      |> translate({-cx, -cy})
      |> do_rotate(deg, rotater_for(sign))
      |> translate({cx, cy})
    end

    @spec origin_rotate(t(), non_neg_integer, 0 | 1) :: t()
    def origin_rotate(pt, deg, sign), do: rotate(pt, {0, 0}, deg, sign)

    defp do_rotate(pt, 0, _), do: pt

    defp do_rotate(pt, deg, rotater),
      do: do_rotate(rotater.(pt), deg - 90, rotater)

    # Given a direction sign (1 for counterclockwise, -1 for clockwise), produces a
    # function that rotates a point by 90 degrees in that direction about the origin.
    defp rotater_for(sign), do: fn {x, y} -> {sign * y, -sign * x} end
  end

  defmodule Ship do
    @enforce_keys [:nav]
    defstruct posn: {0, 0},
              nav: nil

    def navigate(%Ship{} = t, []), do: t

    def navigate(%Ship{nav: %nav_mod{}} = t, [action | actions]) do
      t
      |> nav_mod.do_action(action)
      |> navigate(actions)
    end
  end

  defmodule Nav1 do
    defstruct heading: {1, 0}

    for {dir, norm_vec} <- %{?N => {0, -1}, ?E => {1, 0}, ?S => {0, 1}, ?W => {-1, 0}} do
      def do_action(ship, <<unquote(dir), mag::binary>>) do
        %{ship | posn: Point.translate(ship.posn, unquote(norm_vec), String.to_integer(mag))}
      end
    end

    for {dir, sign} <- %{?L => 1, ?R => -1} do
      def do_action(ship, <<unquote(dir), deg::binary>>) do
        heading = Point.origin_rotate(ship.nav.heading, String.to_integer(deg), unquote(sign))

        %{ship | nav: %Nav1{heading: heading}}
      end
    end

    def do_action(ship, <<?F, mag::binary>>) do
      %{ship | posn: Point.translate(ship.posn, ship.nav.heading, String.to_integer(mag))}
    end
  end

  defmodule Nav2 do
    defstruct waypoint: {10, -1}

    for {dir, norm_vec} <- %{?N => {0, -1}, ?E => {1, 0}, ?S => {0, 1}, ?W => {-1, 0}} do
      def do_action(ship, <<unquote(dir), mag::binary>>) do
        waypoint = Point.translate(ship.nav.waypoint, unquote(norm_vec), String.to_integer(mag))

        %{ship | nav: %Nav2{waypoint: waypoint}}
      end
    end

    for {dir, sign} <- %{?L => 1, ?R => -1} do
      def do_action(%{nav: nav} = ship, <<unquote(dir), deg::binary>>) do
        waypoint = Point.origin_rotate(nav.waypoint, String.to_integer(deg), unquote(sign))

        %{ship | nav: %Nav2{waypoint: waypoint}}
      end
    end

    def do_action(ship, <<?F, mag::binary>>) do
      %{ship | posn: Point.translate(ship.posn, ship.nav.waypoint, String.to_integer(mag))}
    end
  end

  def part1(args) do
    ship = Ship.navigate(%Ship{nav: %Nav1{}}, String.split(args))

    manhattan({0, 0}, ship.posn)
  end

  def part2(args) do
    ship = Ship.navigate(%Ship{nav: %Nav2{}}, String.split(args))

    manhattan({0, 0}, ship.posn)
  end

  defp manhattan({x1, y1}, {x2, y2}), do: abs(x2 - x1) + abs(y2 - y1)
end
