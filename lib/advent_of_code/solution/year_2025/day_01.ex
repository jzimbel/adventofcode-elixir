defmodule AdventOfCode.Solution.Year2025.Day01 do
  use AdventOfCode.Solution.SharedParse

  @start_position 50
  @ticks 100

  @impl true
  def parse(input) do
    input
    |> String.split()
    |> Stream.map(fn
      "L" <> digits -> -String.to_integer(digits)
      "R" <> digits -> String.to_integer(digits)
    end)
    |> Stream.scan(%{position: @start_position}, &move/2)
    |> Enum.to_list()
  end

  def part1(movements), do: Enum.count(movements, &(&1.position == 0))
  def part2(movements), do: Enum.sum_by(movements, & &1.zero_visits)

  defp move(rotation, %{position: position}) do
    %{
      position: Integer.mod(position + rotation, @ticks),
      zero_visits: count_zero_visits(position, rotation)
    }
  end

  # Note: Input never contains "L0" or "R0"--magnitude of a rotation is always nonzero.
  defp count_zero_visits(pos, rot) when rot > 0, do: zv(rot, @ticks - pos)
  defp count_zero_visits(pos, rot) when rot < 0, do: zv(abs(rot), pos)

  defp zv(rot_mag, 0), do: div(rot_mag, @ticks)
  defp zv(rot_mag, zero_dist) when rot_mag >= zero_dist, do: 1 + div(rot_mag - zero_dist, @ticks)
  defp zv(_rot_mag, _zero_dist), do: 0
end
