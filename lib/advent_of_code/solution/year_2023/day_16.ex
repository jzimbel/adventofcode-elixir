defmodule AdventOfCode.Solution.Year2023.Day16 do
  defmodule Silliness do
    defmacro __using__(_) do
      quote do
        import Kernel, only: :macros
        def unquote(:.)(h), do: [h]
        def unquote(:/)({x, y}), do: [{-y, -x}]
        def unquote(:"\\")({x, y}), do: [{y, x}]
        def unquote(:-)({0, _}), do: [{-1, 0}, {1, 0}]
        def unquote(:-)(h), do: [h]
        def unquote(:|)({_, 0}), do: [{0, -1}, {0, 1}]
        def unquote(:|)(h), do: [h]
      end
    end
  end

  defmodule TurnOps, do: use(Silliness)

  alias AdventOfCode.Grid, as: G

  defstruct [:beams, history: MapSet.new()]

  def part1(input) do
    input
    |> G.from_input(&String.to_existing_atom(<<&1>>))
    |> count_energized({{0, 0}, {1, 0}})
  end

  def part2(input) do
    grid = G.from_input(input, &String.to_existing_atom(<<&1>>))

    grid
    |> stream_init_beam_states()
    |> Task.async_stream(&count_energized(grid, &1), ordered: false)
    |> Stream.map(fn {:ok, count} -> count end)
    |> Enum.max()
  end

  defp count_energized(grid, init_beam_state) do
    %__MODULE__{beams: [init_beam_state]}
    |> Stream.iterate(&step_beams(&1, grid))
    |> Enum.find(&match?(%{beams: []}, &1))
    |> then(& &1.history)
    |> MapSet.new(fn {coords, _heading} -> coords end)
    |> MapSet.size()
  end

  defp step_beams(%{beams: beams, history: history}, grid) do
    %__MODULE__{
      beams: Enum.flat_map(beams, &if(&1 in history, do: [], else: step_beam(&1, grid))),
      history: MapSet.union(history, MapSet.new(beams))
    }
  end

  defp step_beam({coords, heading}, %{width: w, height: h} = grid) do
    apply(TurnOps, G.at(grid, coords), [heading])
    |> Stream.map(fn new_heading -> {sum_coords(coords, new_heading), new_heading} end)
    |> Enum.filter(fn {{x, y}, _} -> x in 0..(w - 1)//1 and y in 0..(h - 1)//1 end)
  end

  defp stream_init_beam_states(%{width: w, height: h}) do
    [
      Stream.flat_map(1..(h - 2)//1, fn y -> [{{0, y}, {1, 0}}, {{w - 1, y}, {-1, 0}}] end),
      Stream.flat_map(1..(w - 2)//1, fn x -> [{{x, 0}, {0, 1}}, {{x, h - 1}, {0, -1}}] end),
      Stream.flat_map([{0, 0}, {w - 1, 0}, {0, h - 1}, {w - 1, h - 1}], fn {x, y} ->
        x_headings = if x == 0, do: [0, 1], else: [0, -1]
        y_headings = if y == 0, do: [1, 0], else: [-1, 0]

        for heading <- Enum.zip(x_headings, y_headings), do: {{x, y}, heading}
      end)
    ]
    |> Stream.concat()
  end

  defp sum_coords({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}
end
