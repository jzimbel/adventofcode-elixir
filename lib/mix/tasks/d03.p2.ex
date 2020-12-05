defmodule Mix.Tasks.D03.P2 do
  use Mix.Task

  import AdventOfCode.Day03

  @shortdoc "Day 03 Part 2"
  def run(args) do
    input = AdventOfCode.Input.get!(3, 2020)

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
