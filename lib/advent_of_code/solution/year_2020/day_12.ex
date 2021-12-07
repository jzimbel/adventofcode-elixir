defmodule AdventOfCode.Solution.Year2020.Day12 do
  defmodule Ship do
    @enforce_keys ~w[cursor nav_mod]a
    defstruct posn: {0, 0},
              cursor: nil,
              nav_mod: nil

    def navigate(%Ship{} = t, []), do: t

    def navigate(%Ship{} = t, [action | actions]) do
      t
      |> t.nav_mod.do_action(action)
      |> navigate(actions)
    end
  end

  defmodule Nav1 do
    import AdventOfCode.Point

    def do_action(ship, <<rot_dir, deg::binary>>) when rot_dir in 'LR' do
      %{ship | cursor: rotate(ship.cursor, String.to_integer(deg), rot_dir)}
    end

    def do_action(ship, <<?F, mag::binary>>) do
      %{ship | posn: translate(ship.posn, ship.cursor, String.to_integer(mag))}
    end

    def do_action(ship, <<dir, mag::binary>>) when dir in 'NESW' do
      %{ship | posn: translate(ship.posn, dir, String.to_integer(mag))}
    end
  end

  defmodule Nav2 do
    import AdventOfCode.Point

    def do_action(ship, <<dir, mag::binary>>) when dir in 'NESW' do
      %{ship | cursor: translate(ship.cursor, dir, String.to_integer(mag))}
    end

    def do_action(ship, action) do
      Nav1.do_action(ship, action)
    end
  end

  def part1(args) do
    get_final_posn(%Ship{cursor: {1, 0}, nav_mod: Nav1}, args)
  end

  def part2(args) do
    get_final_posn(%Ship{cursor: {10, -1}, nav_mod: Nav2}, args)
  end

  defp get_final_posn(ship, input) do
    ship
    |> Ship.navigate(String.split(input))
    |> Map.get(:posn)
    |> manhattan({0, 0})
  end

  defp manhattan({x1, y1}, {x2, y2}), do: abs(x2 - x1) + abs(y2 - y1)
end
