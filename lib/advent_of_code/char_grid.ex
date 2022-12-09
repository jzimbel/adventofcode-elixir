defmodule AdventOfCode.CharGrid do
  @moduledoc "Data structure representing a finite grid of characters by a map of {x, y} => char"

  alias __MODULE__, as: T

  @type t :: %T{
          grid: grid,
          width: non_neg_integer,
          height: non_neg_integer
        }

  @typep grid :: %{coordinates => char}

  @type coordinates :: {non_neg_integer, non_neg_integer}

  @type cell :: {coordinates, char}

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

  @spec from_input(String.t()) :: t()
  def from_input(input) do
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
        {{x, y}, char}
      end

    %T{
      grid: grid,
      width: width,
      height: height
    }
  end

  @doc "Gets the value at the given coordinates."
  @spec at(t(), coordinates) :: char | nil
  def at(%T{} = t, coords) do
    t.grid[coords]
  end

  @doc "Applies `fun` to each cell to produce a new CharGrid. `fun` must return a char."
  @spec map(t(), (cell -> char)) :: t()
  def map(%T{} = t, fun) do
    %{t | grid: Map.new(t.grid, fn {coords, _} = cell -> {coords, fun.(cell)} end)}
  end

  @doc "Converts the grid to a list of cells."
  @spec to_list(t()) :: list(cell)
  def to_list(%T{} = t) do
    Map.to_list(t.grid)
  end

  @doc "Returns the number of cells for which `predicate` returns a truthy value."
  @spec count(t(), (cell -> as_boolean(any()))) :: non_neg_integer()
  def count(%T{} = t, predicate) do
    Enum.count(t.grid, predicate)
  end

  @doc "Returns the number of cells containing `char`."
  @spec count_chars(t(), char) :: non_neg_integer()
  def count_chars(%T{} = t, char) do
    count(t, fn {_, c} -> c == char end)
  end

  @doc "Returns a list of cells for which `predicate` returns a truthy value."
  @spec filter_cells(t(), (cell -> as_boolean(any()))) :: list(cell)
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
  @spec adjacent_cells(t(), coordinates, adjacency_type) :: list(cell)
  def adjacent_cells(%T{} = t, coords, adjacency_type \\ :all) do
    @adjacency_deltas_by_type[adjacency_type]
    |> Enum.map(&sum_coordinates(coords, &1))
    |> Enum.map(fn adjacent_coords -> {adjacent_coords, at(t, adjacent_coords)} end)
    |> Enum.reject(fn {_coords, value} -> is_nil(value) end)
  end

  @doc """
  Convenience function that behaves the same as `adjacent_cells/3`,
  but returns only the char value of each adjacent cell.
  """
  @spec adjacent_values(t(), coordinates, adjacency_type) :: list(char)
  def adjacent_values(%T{} = t, coords, adjacency_type \\ :all) do
    t
    |> adjacent_cells(coords, adjacency_type)
    |> Enum.map(&elem(&1, 1))
  end

  @doc """
  Convenience function that behaves the same as `adjacent_cells/3`,
  but returns only the coordinates of each adjacent cell.
  """
  @spec adjacent_coords(t(), coordinates, adjacency_type) :: list(coordinates)
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
  @spec lines_of_cells(t(), coordinates, adjacency_type) :: list(list(cell))
  def lines_of_cells(%T{} = t, coords, adjacency_type \\ :all) do
    @adjacency_deltas_by_type[adjacency_type]
    |> Enum.map(&get_line_of_cells(t, &1, sum_coordinates(coords, &1)))
  end

  @doc """
  Convenience function that behaves the same as `lines_of_cells/3`,
  but returns only the char value of each cell.
  """
  @spec lines_of_values(t(), coordinates, adjacency_type) :: list(list(char))
  def lines_of_values(%T{} = t, coords, adjacency_type \\ :all) do
    t
    |> lines_of_cells(coords, adjacency_type)
    |> Enum.map(fn line -> Enum.map(line, &elem(&1, 1)) end)
  end

  @doc """
  Convenience function that behaves the same as `lines_of_cells/3`,
  but returns only the coordinates of each cell.
  """
  @spec lines_of_coords(t(), coordinates, adjacency_type) :: list(list(coordinates))
  def lines_of_coords(%T{} = t, coords, adjacency_type \\ :all) do
    t
    |> lines_of_cells(coords, adjacency_type)
    |> Enum.map(fn line -> Enum.map(line, &elem(&1, 0)) end)
  end

  @doc """
  Returns a list of values from the up to 8 cells reachable by a chess queen's move from the
  cell at `coords`.

  The optional `empty_char` (default `?.`) dictates which cells are considered unoccupied.
  """
  @spec queen_move_values(t(), coordinates, char) :: list(char)
  def queen_move_values(%T{} = t, coords, empty_char \\ ?.) do
    @all_adjacent_deltas
    |> Enum.map(&find_nonempty_on_line(t, &1, sum_coordinates(coords, &1), empty_char))
    |> Enum.reject(&is_nil/1)
  end

  defp get_line_of_cells(t, step, coords) do
    case at(t, coords) do
      nil -> []
      val -> [{coords, val} | get_line_of_cells(t, step, sum_coordinates(coords, step))]
    end
  end

  defp find_nonempty_on_line(t, step, coords, empty_char) do
    case at(t, coords) do
      ^empty_char -> find_nonempty_on_line(t, step, sum_coordinates(coords, step), empty_char)
      val -> val
    end
  end

  defp sum_coordinates({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}
end
