defmodule AdventOfCode.Day13 do
  def part1(args) do
    {time, buses} = parse_input_p1(args)
    find_earliest_departure(time, buses)
  end

  def part2(args) do
    args
    |> parse_input_p2()
    |> find_earliest_contiguous()
  end

  defp parse_input_p1(input) do
    [time, buses] = String.split(input)

    time = String.to_integer(time)

    buses =
      buses
      |> String.split(",")
      |> Enum.reject(&(&1 == "x"))
      |> Enum.map(&String.to_integer/1)

    {time, buses}
  end

  defp parse_input_p2(input) do
    input
    |> String.split()
    |> Enum.at(1)
    |> String.split(",")
    |> Enum.map(fn
      "x" -> :x
      n -> String.to_integer(n)
    end)
  end

  defp find_earliest_departure(time, buses, wait_time \\ 0) do
    buses
    |> Enum.find(&(rem(time, &1) == 0))
    |> case do
      nil -> find_earliest_departure(time + 1, buses, wait_time + 1)
      n -> n * wait_time
    end
  end

  defp find_earliest_contiguous([bus | buses]) do
    loop(buses, bus, 1, 0, 1)
  end

  defp loop([], _, _, offset, _), do: offset

  defp loop([:x | buses], step, _, offset, minute_offset) do
    loop(buses, step, 1, offset, minute_offset + 1)
  end

  defp loop([bus | buses], step, n, offset, minute_offset)
       when rem(step * n + offset + minute_offset, bus) == 0 do
    loop(buses, step * bus, 1, offset + step * n, minute_offset + 1)
  end

  defp loop(buses, step, n, offset, minute_offset) do
    loop(buses, step, n + 1, offset, minute_offset)
  end
end

# 67,7,59,61

# (67*n+0+1)%7=0
# n=5
# offset=67*5=335

# (67*7*n+335+2)%59=0
# n=14
# offset=67*7*14+335=6901

# (67*7*59*n+6901+3)%61=0
# n=27
# offset=747117+6901=754018

# 754018
