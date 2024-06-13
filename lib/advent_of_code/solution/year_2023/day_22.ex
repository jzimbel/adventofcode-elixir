defmodule AdventOfCode.Solution.Year2023.Day22 do
  require AdventOfCode.Counter.Single, as: Counter

  use AdventOfCode.Solution.SharedParse

  defmodule Brick do
    @enforce_keys [:x, :y, :z, :footprint]
    defstruct @enforce_keys ++ [dropped?: false]

    def new(line) do
      [from, to] = String.split(line, "~")
      [x1, y1, z1] = for n <- String.split(from, ","), do: String.to_integer(n)
      [x2, y2, z2] = for n <- String.split(to, ","), do: String.to_integer(n)

      x = x1..x2//1
      y = y1..y2//1
      %__MODULE__{x: x, y: y, z: z1..z2//1, footprint: footprint(x, y)}
    end

    defp footprint(x_range, y_range), do: for(x <- x_range, y <- y_range, do: {x, y})

    def drop_to_z(b, z) when z == b.z.first, do: %{b | dropped?: true}
    def drop_to_z(b, z), do: %{b | z: Range.shift(b.z, z - b.z.first), dropped?: true}

    def lt?(b1, b2), do: b1.z.last < b2.z.first
  end

  @impl true
  def parse(input) do
    bricks =
      input
      |> String.split("\n", trim: true)
      |> Stream.with_index()
      |> Map.new(fn {line, id} -> {id, Brick.new(line)} end)

    columns =
      for {id, brick} <- bricks, reduce: %{} do
        acc ->
          for xy <- brick.footprint, reduce: acc do
            acc -> Map.update(acc, xy, [id], &insert_brick(&1, id, bricks))
          end
      end

    bricks = drop_all(bricks, columns)

    {bricks, columns}
  end

  def part1({bricks, columns}) do
    load_bearing_bricks =
      bricks
      |> Stream.map(fn {id, brick} ->
        supporting_brick_ids =
          brick.footprint
          |> Stream.map(&adjacent_below(columns[&1], id))
          |> Stream.reject(&is_nil/1)
          |> Stream.filter(fn below_id -> bricks[below_id].z.last + 1 == brick.z.first end)
          |> Enum.uniq()

        case supporting_brick_ids do
          [single_supporting_brick] -> single_supporting_brick
          _ -> nil
        end
      end)
      |> Stream.reject(&is_nil/1)
      |> MapSet.new()

    map_size(bricks) - MapSet.size(load_bearing_bricks)
  end

  # Note: Slow! Takes about 1:00, or 3:00+ without the Task.async_stream.
  # Probably faster way: graph theory!
  # After dropping all bricks, build a directed dependency graph: brick A -> brick B, on which A rests
  # For each brick A, find paths from it to the bottom. If all pass through some brick B, then B is load-bearing and would cause A to fall if removed.
  # For each brick, count number of load-bearing bricks. Sum is the solution.
  def part2({bricks, columns}) do
    bricks = Map.new(bricks, fn {id, brick} -> {id, %{brick | dropped?: false}} end)

    {:ok, counter} = Counter.start_link([])

    bricks
    |> Task.async_stream(__MODULE__, :simulate_removal, [bricks, columns, counter],
      ordered: false
    )
    |> Stream.run()

    drop_count = Counter.value(counter)
    Counter.stop(counter)

    drop_count
  end

  def simulate_removal({id, brick}, bricks, columns, counter) do
    _ = drop_all(Map.delete(bricks, id), delete_from_columns(columns, id, brick), counter)
    nil
  end

  defp delete_from_columns(columns, id, brick) do
    for xy <- brick.footprint, reduce: columns do
      cols -> update_in(cols[xy], &List.delete(&1, id))
    end
  end

  defp drop_all(bricks, columns, counter \\ nil) do
    lowest_undropped_brick =
      bricks
      |> Stream.reject(fn {_, brick} -> brick.dropped? end)
      |> Enum.min_by(fn {_, brick} -> brick.z.first end, fn -> :all_dropped end)

    case lowest_undropped_brick do
      {id, brick} ->
        highest_z_below =
          brick.footprint
          |> Stream.map(&adjacent_below(columns[&1], id))
          |> Stream.reject(&is_nil/1)
          |> Stream.map(&bricks[&1].z.last)
          |> Enum.max(fn -> 0 end)

        new_brick = Brick.drop_to_z(brick, highest_z_below + 1)

        if counter && new_brick.z.first < brick.z.first, do: Counter.increment(counter)
        drop_all(%{bricks | id => new_brick}, columns, counter)

      :all_dropped ->
        bricks
    end
  end

  defp adjacent_below([id | _], id), do: nil
  defp adjacent_below([adjacent_id, id | _], id), do: adjacent_id
  defp adjacent_below(column, id), do: adjacent_below(tl(column), id)

  defp insert_brick(column, new_id, bricks) do
    new_brick = bricks[new_id]
    {l, r} = Enum.split_while(column, &Brick.lt?(bricks[&1], new_brick))
    l ++ [new_id | r]
  end
end
