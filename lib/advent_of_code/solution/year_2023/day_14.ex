defmodule AdventOfCode.Solution.Year2023.Day14 do
  alias AdventOfCode.Grid, as: G
  alias AdventOfCode.Sequence

  use AdventOfCode.Solution.SharedParse

  @impl true
  defdelegate parse(input), to: G, as: :from_input

  def part1(grid) do
    grid
    |> tilt(:n)
    |> rock_load()
  end

  def part2(grid) do
    [:n, :w, :s, :e]
    |> Stream.cycle()
    |> Stream.scan(grid, &tilt(&2, &1))
    |> Stream.drop(3)
    |> Stream.take_every(4)
    |> Stream.with_index(1)
    |> Enum.reduce_while(%{}, fn {grid, i}, indices ->
      case Map.fetch(indices, grid) do
        {:ok, repeat_start} -> {:halt, build_repeat_segment(indices, repeat_start, i - 1)}
        :error -> {:cont, Map.put(indices, grid, i)}
      end
    end)
    |> Sequence.at(1_000_000_000)
  end

  defp build_repeat_segment(indices, start_index, end_index) do
    repeat_indices = start_index..end_index//1

    indices
    |> Stream.filter(fn {_g, j} -> j in repeat_indices end)
    |> Stream.map(fn {g, j} -> {rock_load(g), j} end)
    |> Enum.sort_by(&elem(&1, 1))
  end

  defp tilt(grid, :n), do: do_tilt(grid, &G.cols/1, ?O, &G.from_cols/1)
  defp tilt(grid, :s), do: do_tilt(grid, &G.cols/1, ?., &G.from_cols/1)
  defp tilt(grid, :w), do: do_tilt(grid, &G.rows/1, ?O, &G.from_rows/1)
  defp tilt(grid, :e), do: do_tilt(grid, &G.rows/1, ?., &G.from_rows/1)

  defp do_tilt(grid, to_lanes, char_to_send_forward, from_lanes) do
    grid
    |> to_lanes.()
    |> Enum.map(fn lane ->
      lane
      |> Stream.map(fn {_coords, char} -> char end)
      |> Stream.chunk_by(&(&1 == ?#))
      |> Enum.flat_map(fn
        [?# | _] = l -> l
        l -> char_to_front(l, char_to_send_forward)
      end)
    end)
    |> from_lanes.()
  end

  defp char_to_front(l, char, acc \\ [])
  defp char_to_front([], _char, acc), do: acc
  defp char_to_front([char | rest], char, acc), do: [char | char_to_front(rest, char, acc)]
  defp char_to_front([other | rest], char, acc), do: char_to_front(rest, char, [other | acc])

  defp rock_load(grid) do
    grid
    |> G.rows()
    |> Stream.with_index()
    |> Stream.map(fn {row, i} -> (grid.height - i) * Enum.count(row, &match?({_, ?O}, &1)) end)
    |> Enum.sum()
  end
end
