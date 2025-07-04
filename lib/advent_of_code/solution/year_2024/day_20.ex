defmodule AdventOfCode.Solution.Year2024.Day20 do
  alias AdventOfCode.Grid, as: G
  import AdventOfCode.Algo.Helpers, only: [manhattan_distance: 2]

  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input) do
    grid = G.from_input(input)
    {start, ?S} = Enum.find(grid, &match?({_, ?S}, &1))
    {goal, ?E} = Enum.find(grid, &match?({_, ?E}, &1))
    grid = G.replace(grid, %{start => ?., goal => ?.})

    {grid, start, goal}
  end

  def part1(race_course), do: race_course |> solve(2) |> Enum.count(&(&1 >= 100))
  def part2(race_course), do: race_course |> solve(20) |> Enum.count(&(&1 >= 100))

  def solve({grid, start, goal}, max_jump) do
    # NB: the original path visits all empty cells in the grid, so any valid cheat will end up back on the path.
    {:ok, {path, cost}} = AdventOfCode.Algo.a_star_one(grid, start, goal)
    cheat_savings(Enum.with_index(path), max_jump, cost, [])
  end

  defp cheat_savings([], _, _, acc), do: acc

  defp cheat_savings([{coords, cost_up_to_jump} | path], max_jump, total_cost, acc) do
    savings =
      for {other_coords, cost_up_to_other_coords} <- path,
          Enum.member?(2..max_jump//1, jump_dist = manhattan_distance(coords, other_coords)),
          0 < (saved = cost_up_to_other_coords - cost_up_to_jump - jump_dist),
          do: saved

    cheat_savings(path, max_jump, total_cost, savings ++ acc)
  end
end
