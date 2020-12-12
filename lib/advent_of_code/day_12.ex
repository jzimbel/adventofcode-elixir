defmodule AdventOfCode.Day12 do
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
    import AdventOfCode.Point

    defstruct heading: {1, 0}

    for {dir, norm_vec} <- %{?N => {0, -1}, ?E => {1, 0}, ?S => {0, 1}, ?W => {-1, 0}} do
      def do_action(ship, <<unquote(dir), mag::binary>>) do
        %{ship | posn: translate(ship.posn, unquote(norm_vec), String.to_integer(mag))}
      end
    end

    for {dir, sign} <- %{?L => 1, ?R => -1} do
      def do_action(ship, <<unquote(dir), deg::binary>>) do
        heading = rotate(ship.nav.heading, String.to_integer(deg), unquote(sign))

        %{ship | nav: %Nav1{heading: heading}}
      end
    end

    def do_action(ship, <<?F, mag::binary>>) do
      %{ship | posn: translate(ship.posn, ship.nav.heading, String.to_integer(mag))}
    end
  end

  defmodule Nav2 do
    import AdventOfCode.Point

    defstruct waypoint: {10, -1}

    for {dir, norm_vec} <- %{?N => {0, -1}, ?E => {1, 0}, ?S => {0, 1}, ?W => {-1, 0}} do
      def do_action(ship, <<unquote(dir), mag::binary>>) do
        waypoint = translate(ship.nav.waypoint, unquote(norm_vec), String.to_integer(mag))

        %{ship | nav: %Nav2{waypoint: waypoint}}
      end
    end

    for {dir, sign} <- %{?L => 1, ?R => -1} do
      def do_action(%{nav: nav} = ship, <<unquote(dir), deg::binary>>) do
        waypoint = rotate(nav.waypoint, String.to_integer(deg), unquote(sign))

        %{ship | nav: %Nav2{waypoint: waypoint}}
      end
    end

    def do_action(ship, <<?F, mag::binary>>) do
      %{ship | posn: translate(ship.posn, ship.nav.waypoint, String.to_integer(mag))}
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
