defmodule AdventOfCode.Solution.Year2021.Day22 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&clamp/1)
    |> total_volume()
  end

  def part2(input) do
    input
    |> parse_input()
    |> total_volume()
  end

  defp total_volume(cuboids) do
    cuboids
    |> Enum.reduce([], &switch_region/2)
    |> Enum.map(&volume/1)
    |> Enum.sum()
  end

  defp switch_region({:on, on_cuboid}, cuboids) do
    subtract_from_all([on_cuboid], cuboids) ++ cuboids
  end

  defp switch_region({:off, off_cuboid}, cuboids) do
    subtract_from_all(cuboids, [off_cuboid])
  end

  defp subtract_from_all(lhs_cuboids, rhs_cuboids) do
    Enum.reduce(rhs_cuboids, lhs_cuboids, fn rhs_cuboid, lhs_acc ->
      Enum.flat_map(lhs_acc, &subtract(&1, rhs_cuboid))
    end)
  end

  defp subtract(lhs_cuboid, rhs_cuboid) do
    if disjoint?(lhs_cuboid, rhs_cuboid) do
      [lhs_cuboid]
    else
      {xmin1..xmax1//1, ymin1..ymax1//1 = y, zmin1..zmax1//1 = z} = lhs_cuboid
      {xmin2..xmax2//1, ymin2..ymax2//1, zmin2..zmax2//1} = rhs_cuboid

      x_clamped = max(xmin1, xmin2)..min(xmax1, xmax2)//1
      y_clamped = max(ymin1, ymin2)..min(ymax1, ymax2)//1

      [
        {xmin1..(xmin2 - 1)//1, y, z},
        {(xmax2 + 1)..xmax1//1, y, z},
        {x_clamped, ymin1..(ymin2 - 1)//1, z},
        {x_clamped, (ymax2 + 1)..ymax1//1, z},
        {x_clamped, y_clamped, zmin1..(zmin2 - 1)//1},
        {x_clamped, y_clamped, (zmax2 + 1)..zmax1//1}
      ]
      |> Enum.reject(&(volume(&1) == 0))
    end
  end

  defp clamp({action, {x, y, z}}) do
    {action, {clamp(x), clamp(y), clamp(z)}}
  end

  defp clamp(lower..upper//1) do
    max(lower, -50)..min(upper, 50)//1
  end

  defp volume({x, y, z}) do
    Range.size(x) * Range.size(y) * Range.size(z)
  end

  defp disjoint?({x1, y1, z1}, {x2, y2, z2}) do
    Range.disjoint?(x1, x2) or Range.disjoint?(y1, y2) or Range.disjoint?(z1, z2)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.split()
    |> then(fn [on_off, cuboid] ->
      {String.to_existing_atom(on_off), parse_cuboid(cuboid)}
    end)
  end

  defp parse_cuboid(cuboid) do
    ~r/(-?\d+)..(-?\d+)/
    |> Regex.scan(cuboid, capture: :all_but_first)
    |> Enum.map(fn [lower, upper] ->
      String.to_integer(lower)..String.to_integer(upper)//1
    end)
    |> List.to_tuple()
  end
end
