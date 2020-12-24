defmodule AdventOfCode.CharGrid do
  @moduledoc "Data structure representing a grid of characters by a map of {x, y} => char"

  alias __MODULE__, as: T

  @type t :: %T{
          grid: grid,
          width: non_neg_integer,
          height: non_neg_integer
        }

  @typep grid :: %{coordinates => char}

  @type coordinates :: {non_neg_integer, non_neg_integer}

  @enforce_keys ~w[grid width height]a
  defstruct @enforce_keys

  # List of coords that produce the 8 coordinates surrounding a given coord when added to it
  @adjacent_deltas for x <- -1..1, y <- -1..1, not (x == 0 and y == 0), do: {x, y}

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

  @doc "Applies `fun` to each cell in the CharGrid to produce a new CharGrid."
  @spec map(t(), ({coordinates, char} -> char)) :: t()
  def map(%T{} = t, fun) do
    %{t | grid: for({coords, _} = entry <- t.grid, into: %{}, do: {coords, fun.(entry)})}
  end

  @doc "Returns the number of cells in the CharGrid for which `fun` returns a truthy value."
  @spec count(t(), ({coordinates, char} -> as_boolean(term))) :: non_neg_integer()
  def count(%T{} = t, fun) do
    Enum.count(t.grid, fun)
  end

  @doc "Returns a list of values from the up to 8 cells adjacent to the one at `coords`."
  @spec adjacent_values(t(), coordinates) :: list(char)
  def adjacent_values(%T{} = t, coords) do
    @adjacent_deltas
    |> Enum.map(&sum_coordinates(coords, &1))
    |> Enum.map(&at(t, &1))
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Returns a list of values from the up to 8 cells reachable by a chess queen's move from the
  cell at `coords`.

  The optional `empty_char` (default `?.`) dictates which cells are considered unoccupied.
  """
  @spec queen_move_values(t(), coordinates, char) :: list(char)
  def queen_move_values(%T{} = t, coords, empty_char \\ ?.) do
    @adjacent_deltas
    |> Enum.map(&find_nonempty_on_line(t, &1, sum_coordinates(coords, &1), empty_char))
    |> Enum.reject(&is_nil/1)
  end

  defp find_nonempty_on_line(t, step, coords, empty_char) do
    case at(t, coords) do
      ^empty_char -> find_nonempty_on_line(t, step, sum_coordinates(coords, step), empty_char)
      val -> val
    end
  end

  defp sum_coordinates({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}
end
