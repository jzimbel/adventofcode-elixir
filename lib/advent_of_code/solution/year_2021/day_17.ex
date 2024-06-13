defmodule AdventOfCode.Solution.Year2021.Day17 do
  def part1(input) do
    {_x_target, ymin..ymax//1} = target = parse_input(input)

    -ymin..-ymax//-1
    |> Stream.map(&simulate_shot({0, &1}, target))
    |> Enum.find(&first_step_hit?(&1, target))
    |> Stream.map(fn {_x, y} -> y end)
    |> Enum.max()
  end

  def part2(input) do
    {_xmin..xmax//1, ymin.._ymax//1} = target = parse_input(input)

    for(vx <- 0..xmax//1, vy <- ymin..-ymin//1, do: {vx, vy})
    |> Stream.map(&simulate_shot(&1, target))
    |> Enum.count(&hits_target?(&1, target))
  end

  defp simulate_shot(v, target) do
    {v, {0, 0}}
    |> Stream.iterate(&step/1)
    |> Stream.map(&elem(&1, 1))
    |> Stream.take_while(&in_simulation_bounds?(&1, target))
  end

  defp step({{vx, vy}, {x, y}}) do
    {{vx - unit(vx), vy - 1}, {x + vx, y + vy}}
  end

  defp in_simulation_bounds?({x, y}, {xmin..xmax//1, ymin.._ymax//1}) do
    x in min(0, xmin)..max(0, xmax)//1 and y >= ymin
  end

  # Detects shots where the probe hits the target's y bounds on its first step below y=0
  defp first_step_hit?(shot, {_x_target, y_target}) do
    shot
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.any?(fn [{_x1, y1}, {_x2, y2}] -> y1 >= 0 and y2 in y_target end)
  end

  defp hits_target?(shot, target) do
    Enum.any?(shot, &on_target?(&1, target))
  end

  defp on_target?({x, y}, {x_target, y_target}) do
    x in x_target and y in y_target
  end

  defp parse_input(input) do
    ~r/(-?\d+)\.\.(-?\d+)/
    |> Regex.scan(input, capture: :all_but_first)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> then(fn [xmin, xmax, ymin, ymax] ->
      {xmin..xmax//1, ymin..ymax//1}
    end)
  end

  defp unit(0), do: 0
  defp unit(n) when n > 0, do: 1
  defp unit(_n), do: -1
end
