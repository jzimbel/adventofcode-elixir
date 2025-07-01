defmodule AdventOfCode.Solution.Year2024.Day16 do
  alias AdventOfCode.Grid, as: G
  alias AdventOfCode.Algo

  use AdventOfCode.Solution.SharedParse

  defmodule DeerRaceImpl do
    use AdventOfCode.Algo.AStar.Impl
    import Algo.Helpers

    @impl true
    def next(state, search) do
      {coords, _heading} = state.current

      for {neighbor, ?.} <- G.adjacent_cells(search.grid, coords, :cardinal),
          next = {neighbor, subtract(neighbor, coords)},
          cost = cost(state.current, next),
          # Shortest path will never contain a U-turn.
          cost != 2001 do
        %Algo.AStar.State{
          current: next,
          heuristic: heuristic(next, search.goal),
          score: state.score + cost,
          came_from: Map.put(state.came_from, next, state.current)
        }
      end
    end

    @impl true
    def at_goal?(state, goal_coords) do
      {coords, _heading} = state.current
      coords == goal_coords
    end

    def heuristic({coords, _heading} = current, goal) do
      min_turns(current, goal) * 1000 + manhattan_distance(coords, goal)
    end

    defp cost({_, heading1}, {_, heading2}) do
      cond do
        heading1 == heading2 -> 1
        # U-turn
        heading1 == invert(heading2) -> 2001
        :else -> 1001
      end
    end

    defp min_turns({coords, heading}, goal) do
      {x, y} = heading
      {goal_vx, goal_vy} = subtract(goal, coords)

      gx = sign(goal_vx)
      gy = sign(goal_vy)

      min(abs(x - gx) + abs(y - gy), 2)
    end

    defp subtract({x1, y1}, {x2, y2}), do: {x1 - x2, y1 - y2}
    defp invert({x, y}), do: {-x, -y}

    defp sign(0), do: 0
    defp sign(n) when n > 0, do: 1
    defp sign(n) when n < 0, do: -1
  end

  @impl true
  def parse(input) do
    grid = G.from_input(input)

    {start_coords, ?S} = Enum.find(grid, &match?({_, ?S}, &1))
    {goal_coords, ?E} = Enum.find(grid, &match?({_, ?E}, &1))

    grid = G.replace_many(grid, %{start_coords => ?., goal_coords => ?.})
    start_position = {start_coords, {1, 0}}

    start = %AdventOfCode.Algo.AStar.State{
      current: start_position,
      heuristic: DeerRaceImpl.heuristic(start_position, goal_coords)
    }

    IO.inspect(map_size(grid.grid) * 4, label: "# of possible states")

    {grid, start, goal_coords}
  end

  def part1({grid, start, goal}) do
    {_path, cost} =
      grid
      |> Algo.a_star(start, goal, DeerRaceImpl)
      |> Enum.fetch!(0)

    cost
  end

  def part2({grid, start, goal}) do
    all_shortest_paths =
      grid
      |> Algo.a_star(start, goal, DeerRaceImpl)
      |> Stream.map(fn {path, _cost} -> Enum.map(path, fn {coords, _heading} -> coords end) end)

    all_shortest_paths
    |> Stream.flat_map(& &1)
    |> Stream.uniq()
    |> Enum.count()
  end
end
