defmodule AdventOfCode.Solution.Year2025.Day06 do
  defp eval([?+ | ns]), do: Enum.sum(ns)
  defp eval([?* | ns]), do: Enum.product(ns)

  ##########
  # Part 1 #
  ##########

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(fn
        "+" -> ?+
        "*" -> ?*
        n -> String.to_integer(n)
      end)
    end)
    |> reverse_transpose()
    |> Enum.sum_by(&eval/1)
  end

  defp reverse_transpose(lists, acc \\ [])

  defp reverse_transpose([[] | _], acc), do: acc

  defp reverse_transpose(lists, acc) do
    {tails, col_rev} = Enum.map_reduce(lists, [], fn [h | t], acc -> {t, [h | acc]} end)
    reverse_transpose(tails, [col_rev | acc])
  end

  ##########
  # Part 2 #
  ##########

  use TypedStruct

  defmodule StringGrid do
    @moduledoc """
    Structure to facilitate accessing chars from a grid-shaped string by `{x,y}` index.

    `{0,0}` is the first character in the string, i.e., the top left corner of the grid.
    """
    # (width does not include newlines)
    @enforce_keys [:s, :width, :height]
    defstruct @enforce_keys

    def new(s) do
      {width, _} = :binary.match(s, "\n")
      height = div(byte_size(s), width + 1)
      %__MODULE__{s: s, width: width, height: height}
    end

    def at(%__MODULE__{} = sg, {x, y}) do
      :binary.at(sg.s, x + y * (sg.width + 1))
    end
  end

  typedstruct module: State do
    field :sum, non_neg_integer, default: 0
    field :terms, [pos_integer], default: []
    field :term, pos_integer | nil, default: nil
  end

  def part2(input) do
    grid = StringGrid.new(input)

    %State{sum: sum} =
      for x <- (grid.width - 1)..0//-1,
          y <- 0..(grid.height - 1)//1,
          reduce: %State{} do
        state -> grid |> StringGrid.at({x, y}) |> process_char(state)
      end

    sum
  end

  defp process_char(?\s, %{term: nil} = state), do: state

  defp process_char(?\s, %{term: n} = state) do
    %{state | terms: [n | state.terms], term: nil}
  end

  defp process_char(op, %{term: nil} = state) when op in ~c"+*" do
    %State{sum: state.sum + eval([op | state.terms])}
  end

  defp process_char(op, state) when op in ~c"+*" do
    process_char(op, %{state | terms: [state.term | state.terms], term: nil})
  end

  defp process_char(n, %{term: nil} = state), do: %{state | term: n - ?0}

  defp process_char(n, state), do: %{state | term: state.term * 10 + n - ?0}

  ##############################
  # Original Grid-based part 2 #
  ##############################

  alias AdventOfCode.Grid, as: G

  def part2_original(input) do
    grid = G.from_input(input)

    blank_col_xs =
      for x <- 0..(grid.width - 1)//1,
          G.at(grid, {x, 0}) == ?\s,
          G.line_of_cells(grid, {x, 0}, :s, true) |> Enum.all?(&match?({_, ?\s}, &1)),
          do: x

    x_ranges =
      Stream.concat([[-1], blank_col_xs, [grid.width]])
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [l_blank, r_blank] -> (l_blank + 1)..(r_blank - 1)//1 end)

    subgrids =
      for x_range <- x_ranges do
        G.from_cells(
          for(
            x <- x_range,
            y <- 0..(grid.height - 1)//1,
            do: {{x - x_range.first, y}, G.at(grid, {x, y})}
          )
        )
      end

    Enum.sum_by(subgrids, &eval_grid/1)
  end

  defp eval_grid(grid) do
    op =
      case G.at(grid, {0, grid.height - 1}) do
        ?+ -> ?+
        ?* -> ?*
      end

    ns =
      for x <- (grid.width - 1)..0//-1 do
        for(y <- 0..(grid.height - 2)//1, do: G.at(grid, {x, y}))
        |> :string.trim()
        |> :erlang.list_to_integer()
      end

    eval([op | ns])
  end
end
