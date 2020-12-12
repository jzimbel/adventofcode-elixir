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

    def do_action(ship, <<dir, mag::binary>>) when dir in 'NESW' do
      posn = translate(ship.posn, dir, String.to_integer(mag))
      %{ship | posn: posn}
    end

    def do_action(ship, <<rot_dir, deg::binary>>) when rot_dir in 'LR' do
      heading = rotate(ship.nav.heading, String.to_integer(deg), rot_dir)
      %{ship | nav: %{ship.nav | heading: heading}}
    end

    def do_action(ship, <<?F, mag::binary>>) do
      posn = translate(ship.posn, ship.nav.heading, String.to_integer(mag))
      %{ship | posn: posn}
    end
  end

  defmodule Nav2 do
    import AdventOfCode.Point

    defstruct waypoint: {10, -1}

    def do_action(ship, <<dir, mag::binary>>) when dir in 'NESW' do
      waypoint = translate(ship.nav.waypoint, dir, String.to_integer(mag))
      %{ship | nav: %{ship.nav | waypoint: waypoint}}
    end

    def do_action(ship, <<rot_dir, deg::binary>>) when rot_dir in 'LR' do
      waypoint = rotate(ship.nav.waypoint, String.to_integer(deg), rot_dir)
      %{ship | nav: %{ship.nav | waypoint: waypoint}}
    end

    def do_action(ship, <<?F, mag::binary>>) do
      posn = translate(ship.posn, ship.nav.waypoint, String.to_integer(mag))
      %{ship | posn: posn}
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
