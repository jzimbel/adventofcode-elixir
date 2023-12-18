defmodule AdventOfCode.Grid do
  @moduledoc "Data structure representing a finite grid of values by a map of {x, y} => value"

  alias __MODULE__, as: T

  @type t(a) :: %T{
          grid: grid(a),
          width: non_neg_integer,
          height: non_neg_integer
        }

  @type t :: t(term)

  @typep grid(a) :: %{coordinates => a}

  @type coordinates :: {non_neg_integer, non_neg_integer}

  @type cell(a) :: {coordinates, a}
  @type cell :: cell(term)

  @enforce_keys ~w[grid width height]a
  defstruct @enforce_keys

  # List of coords that produce the 8 coordinates surrounding a given coord when added to it
  @all_adjacent_deltas for x <- -1..1, y <- -1..1, not (x == 0 and y == 0), do: {x, y}

  # List of coords that produce the 4 coordinates horizontally/vertically adjacent to a given coord when added to it
  @cardinal_adjacent_deltas for x <- -1..1, y <- -1..1, abs(x) + abs(y) == 1, do: {x, y}

  # List of coords that produce the 4 coordinates diagonally adjacent to a given coord when added to it
  @intercardinal_adjacent_deltas for x <- -1..1, y <- -1..1, abs(x) + abs(y) == 2, do: {x, y}

  @adjacency_deltas_by_type %{
    all: @all_adjacent_deltas,
    cardinal: @cardinal_adjacent_deltas,
    intercardinal: @intercardinal_adjacent_deltas
  }

  @spec from_input(String.t()) :: t(char)
  @spec from_input(String.t(), (char -> a)) :: t(a) when a: var
  def from_input(input, mapper \\ &Function.identity/1) do
    charlists =
      input
      |> String.split()
      |> Enum.map(&String.to_charlist/1)

    height = length(charlists)
    width = length(hd(charlists))

    grid =
      for {line, y} <- Enum.with_index(charlists),
          {char, x} <- Enum.with_index(line),
          into: %{} do
        {{x, y}, mapper.(char)}
      end

    %T{
      grid: grid,
      width: width,
      height: height
    }
  end

  @doc """
  Creates a Grid from a list of cell values.

  By default, an exception will be raised if `cells` is sparse--that is, if it is
  missing one or more entries within the bounding box of x=0..max(x_coords), y=0..max(y_coords).

  Pass a 0-arity function as a second arg if you want missing entries to be filled
  in with a default value. E.g. `fn -> ?. end`.
  """
  @spec from_cells(list(cell(a))) :: t(a) when a: var
  @spec from_cells(list(cell(a)), (() -> a)) :: t(a) when a: var
  def from_cells(cells, default_fn \\ fn -> raise "`Grid.from_cells`: missing coords" end) do
    width = Stream.map(cells, &elem(elem(&1, 0), 0)) |> Enum.max()
    height = Stream.map(cells, &elem(elem(&1, 0), 1)) |> Enum.max()
    tentative_grid = Map.new(cells)

    grid =
      for x <- 0..(width - 1)//1,
          y <- 0..(height - 1)//1,
          into: %{} do
        {{x, y}, Map.get_lazy(tentative_grid, {x, y}, default_fn)}
      end

    %T{grid: grid, width: width, height: height}
  end

  @doc "Returns all cells in the grid, grouped into rows starting from the top."
  @spec rows(t(a)) :: list(list(cell(a))) when a: var
  def rows(%T{} = t) do
    for y <- 0..(t.height - 1)//1 do
      for x <- 0..(t.width - 1)//1 do
        {{x, y}, t.grid[{x, y}]}
      end
    end
  end

  @doc "Returns all cells in the grid, grouped into columns starting from the left."
  @spec cols(t(a)) :: list(list(cell(a))) when a: var
  def cols(%T{} = t) do
    for x <- 0..(t.width - 1)//1 do
      for y <- 0..(t.height - 1)//1 do
        {{x, y}, t.grid[{x, y}]}
      end
    end
  end

  @doc "Gets the value at the given coordinates."
  @spec at(t(a), coordinates) :: a | nil when a: var
  @spec at(t(a), coordinates, default) :: a | default when a: var, default: var
  def at(%T{} = t, coords, default \\ nil) do
    Map.get(t.grid, coords, default)
  end

  @doc "Applies `fun` to each cell to produce a new Grid."
  @spec map(t(a), (cell(a) -> b)) :: t(b) when a: var, b: var
  def map(%T{} = t, fun) do
    %{t | grid: Map.new(t.grid, fn {coords, _} = cell -> {coords, fun.(cell)} end)}
  end

  @doc "Converts the grid to a list of cells."
  @spec to_list(t(a)) :: list(cell(a)) when a: var
  def to_list(%T{} = t) do
    Map.to_list(t.grid)
  end

  @doc "Returns the number of cells for which `predicate` returns a truthy value."
  @spec count(t(a), (cell(a) -> as_boolean(any()))) :: non_neg_integer() when a: var
  def count(%T{} = t, predicate) do
    Enum.count(t.grid, predicate)
  end

  @doc "Returns the number of cells containing `value`."
  @spec count_values(t(term), term) :: non_neg_integer()
  def count_values(%T{} = t, value) do
    count(t, &match?({_, ^value}, &1))
  end

  @doc "Returns a list of cells for which `predicate` returns a truthy value."
  @spec filter_cells(t(a), (cell(a) -> as_boolean(any()))) :: list(cell(a)) when a: var
  def filter_cells(%T{} = t, predicate) do
    Enum.filter(t.grid, predicate)
  end

  @type adjacency_type :: :all | :cardinal | :intercardinal

  @doc """
  Returns a list of cells adjacent to the one at `coords`.

  The type of adjacency is determined by the third argument:

  - `:all` (default behavior):
    ```
    OOO
    O*O
    OOO
    ```
  - `:cardinal`:
    ```
    .O.
    O*O
    .O.
    ```
  - `:intercardinal`:
    ```
    O.O
    .*.
    O.O
    ```
  """
  @spec adjacent_cells(t(a), coordinates, adjacency_type) :: list(cell(a)) when a: var
  def adjacent_cells(%T{} = t, coords, adjacency_type \\ :all) do
    @adjacency_deltas_by_type[adjacency_type]
    |> Enum.map(&sum_coordinates(coords, &1))
    |> Enum.map(fn adjacent_coords -> {adjacent_coords, at(t, adjacent_coords)} end)
    |> Enum.reject(fn {_coords, value} -> is_nil(value) end)
  end

  @doc """
  Convenience function that behaves the same as `adjacent_cells/3`,
  but returns only the value of each adjacent cell.
  """
  @spec adjacent_values(t(a), coordinates, adjacency_type) :: list(a) when a: var
  def adjacent_values(%T{} = t, coords, adjacency_type \\ :all) do
    t
    |> adjacent_cells(coords, adjacency_type)
    |> Enum.map(&elem(&1, 1))
  end

  @doc """
  Convenience function that behaves the same as `adjacent_cells/3`,
  but returns only the coordinates of each adjacent cell.
  """
  @spec adjacent_coords(t(term), coordinates, adjacency_type) :: list(coordinates)
  def adjacent_coords(%T{} = t, coords, adjacency_type \\ :all) do
    t
    |> adjacent_cells(coords, adjacency_type)
    |> Enum.map(&elem(&1, 0))
  end

  @doc """
  Returns a list of lists of cells in lines from the one at `coords`.
  Each list starts with the cell nearest `coords`, and radiates outward.

  The type of adjacency is determined by the third argument:

  - `:all` (default behavior):
    ```
    O.O.O
    .OOO.
    OO*OO
    .OOO.
    O.O.O
    ```
  - `:cardinal`:
    ```
    ..O..
    ..O..
    OO*OO
    ..O..
    ..O..
    ```
  - `:intercardinal`:
    ```
    O...O
    .O.O.
    ..*..
    .O.O.
    O...O
    ```
  """
  @spec lines_of_cells(t(a), coordinates, adjacency_type) :: list(list(cell(a))) when a: var
  def lines_of_cells(%T{} = t, coords, adjacency_type \\ :all) do
    @adjacency_deltas_by_type[adjacency_type]
    |> Enum.map(&get_line_of_cells(t, &1, sum_coordinates(coords, &1)))
  end

  @doc """
  Convenience function that behaves the same as `lines_of_cells/3`,
  but returns only the value of each cell.
  """
  @spec lines_of_values(t(a), coordinates, adjacency_type) :: list(list(a)) when a: var
  def lines_of_values(%T{} = t, coords, adjacency_type \\ :all) do
    t
    |> lines_of_cells(coords, adjacency_type)
    |> Enum.map(fn line -> Enum.map(line, &elem(&1, 1)) end)
  end

  @doc """
  Convenience function that behaves the same as `lines_of_cells/3`,
  but returns only the coordinates of each cell.
  """
  @spec lines_of_coords(t(term), coordinates, adjacency_type) :: list(list(coordinates))
  def lines_of_coords(%T{} = t, coords, adjacency_type \\ :all) do
    t
    |> lines_of_cells(coords, adjacency_type)
    |> Enum.map(fn line -> Enum.map(line, &elem(&1, 0)) end)
  end

  @doc """
  Returns a list of values from the up to 8 cells reachable by a chess queen's move from the
  cell at `coords`.

  The optional `empty_value` (default `?.`) dictates which cells are considered unoccupied.
  """
  @spec queen_move_values(t(a), coordinates, a) :: list(a) when a: var
  def queen_move_values(%T{} = t, coords, empty_value \\ ?.) do
    @all_adjacent_deltas
    |> Enum.map(&find_nonempty_on_line(t, &1, sum_coordinates(coords, &1), empty_value))
    |> Enum.reject(&is_nil/1)
  end

  defp get_line_of_cells(t, step, coords) do
    case at(t, coords) do
      nil -> []
      val -> [{coords, val} | get_line_of_cells(t, step, sum_coordinates(coords, step))]
    end
  end

  defp find_nonempty_on_line(t, step, coords, empty_value) do
    case at(t, coords) do
      ^empty_value -> find_nonempty_on_line(t, step, sum_coordinates(coords, step), empty_value)
      val -> val
    end
  end

  defp sum_coordinates({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}
end
