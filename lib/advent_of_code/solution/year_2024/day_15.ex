defmodule AdventOfCode.Solution.Year2024.Day15 do
  alias AdventOfCode.Grid, as: G

  def part1(input) do
    {robot, grid, moves} = parse_p1(input)
    {_robot, grid} = Enum.reduce(moves, {robot, grid}, &move_p1/2)
    score(grid, ?O)
  end

  def part2(input) do
    {robot, grid, moves} = parse_p2(input)
    {_robot, grid} = Enum.reduce(moves, {robot, grid}, &move_p2/2)
    score(grid, ?[)
  end

  defp score(grid, box_char) do
    for {point, ^box_char} <- grid, reduce: 0 do
      acc -> acc + box_gps(point)
    end
  end

  defp move_p1(heading, {robot, grid}) do
    next_robot = G.sum_coordinates(robot, heading)

    case G.at(grid, next_robot) do
      ?. ->
        {next_robot, grid}

      ?# ->
        {robot, grid}

      ?O ->
        grid
        |> G.line_of_cells(next_robot, heading, true)
        |> Enum.find(fn {_point, c} -> c != ?O end)
        |> case do
          {_point, ?#} -> {robot, grid}
          {point, ?.} -> {next_robot, G.swap_cells(grid, next_robot, point)}
        end
    end
  end

  defp move_p2(heading, {robot, grid}) do
    next_robot = G.sum_coordinates(robot, heading)

    case G.at(grid, next_robot) do
      ?. -> {next_robot, grid}
      ?# -> {robot, grid}
      box when box in ~C"[]" -> try_push(robot, next_robot, heading, grid)
    end
  end

  defp try_push(robot, against, heading, grid)

  # Horizontal push
  defp try_push(robot, against, {_x, 0} = heading, grid) do
    grid
    |> G.line_of_cells(against, heading, true)
    |> Enum.find(fn {_point, c} -> c not in ~c"[]" end)
    |> case do
      {_point, ?#} -> {robot, grid}
      {point, ?.} -> {against, slide_cells(grid, robot, point, heading)}
    end
  end

  # Vertical push
  defp try_push(robot, against, {0, _y} = heading, grid) do
    to_push = get_boxes_to_push(against, heading, grid)
    cleared = Map.new(to_push, fn {point, _char} -> {point, ?.} end)
    pushed = Map.new(to_push, fn {point, char} -> {G.sum_coordinates(point, heading), char} end)
    updater = Map.merge(cleared, pushed)

    grid = G.replace(grid, updater)
    {against, grid}
  catch
    # `get_boxes_to_push` throws :wall if it encounters a wall
    :wall -> {robot, grid}
  end

  defp get_boxes_to_push(box_part, heading, grid) do
    char = G.at(grid, box_part)
    box_cell_a = {box_part, char}

    box_cell_b =
      case char do
        ?[ -> G.adjacent_cell(grid, box_part, :e)
        ?] -> G.adjacent_cell(grid, box_part, :w)
      end

    get_boxes_to_push([box_cell_a, box_cell_b], heading, grid, [])
  end

  defp get_boxes_to_push([], _, _, acc), do: acc

  defp get_boxes_to_push(fringe, heading, grid, acc) do
    next_fringe =
      fringe
      |> Enum.flat_map(fn {point, _char} ->
        case G.adjacent_cell(grid, point, heading) do
          {_p, box} = cell when box in ~c"[]" -> complete_box(cell)
          {_p, ?.} -> []
          {_p, ?#} -> throw(:wall)
        end
      end)

    get_boxes_to_push(next_fringe, heading, grid, fringe ++ acc)
  end

  defp complete_box({point, ?[} = cell), do: [cell, {G.sum_coordinates(point, {1, 0}), ?]}]
  defp complete_box({point, ?]} = cell), do: [{G.sum_coordinates(point, {-1, 0}), ?[}, cell]

  defp slide_cells(grid, robot, into, heading) do
    cells =
      grid
      |> G.line_of_cells(robot, heading, true)
      |> Enum.take_while(&(not match?({^into, ?.}, &1)))

    first_empty = put_elem(hd(cells), 1, ?.)
    shifted = Enum.map(cells, fn {point, char} -> {G.sum_coordinates(point, heading), char} end)
    replacements = Map.new([first_empty | shifted])
    G.replace(grid, replacements)
  end

  defp box_gps({x, y}), do: x + 100 * y

  defp parse_p1(input) do
    [map, moves] = String.split(input, "\n\n")
    {robot, grid} = parse_robot_and_grid(map)
    {robot, grid, parse_moves(moves)}
  end

  defp parse_p2(input) do
    [map, moves] = String.split(input, "\n\n")
    map = widen(map)
    {robot, grid} = parse_robot_and_grid(map)
    {robot, grid, parse_moves(moves)}
  end

  defp widen(map) do
    map
    |> String.to_charlist()
    |> Enum.map(fn
      ?# -> ~c"##"
      ?O -> ~c"[]"
      ?. -> ~c".."
      ?@ -> ~c"@."
      other -> other
    end)
    |> IO.chardata_to_string()
  end

  defp parse_robot_and_grid(map) do
    grid = G.from_input(map)
    {robot, ?@} = Enum.find(grid, &match?({_, ?@}, &1))
    grid = G.replace(grid, robot, ?.)
    {robot, grid}
  end

  defp parse_moves(moves) do
    moves
    |> String.replace("\n", "")
    |> String.to_charlist()
    |> Enum.map(fn
      ?^ -> {0, -1}
      ?> -> {1, 0}
      ?v -> {0, 1}
      ?< -> {-1, 0}
    end)
  end
end
