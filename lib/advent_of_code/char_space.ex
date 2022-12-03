defmodule AdventOfCode.CharSpace do
  @moduledoc "Generalized implementation of an infinite N-dimensional grid of characters."

  defmacro __using__(dimensions_mod: dim_mod) do
    quote do
      alias __MODULE__, as: T

      @dim_mod unquote(dim_mod)

      @mod_short_name T |> Module.split() |> Enum.take(-2) |> Enum.join(".")

      @type t :: %T{
              grid: grid,
              empty_char: char
            }

      @typep grid :: %{coordinates => char}

      @type coordinates :: @dim_mod.coordinates

      @adjacent_deltas @dim_mod.adjacent_deltas()

      defstruct ~w[grid empty_char]a

      @doc "Creates a new #{@mod_short_name} from a puzzle input string."
      @spec from_input(String.t(), char) :: t()
      def from_input(input, empty_char \\ ?.) do
        charlists =
          input
          |> String.split()
          |> Enum.map(&String.to_charlist/1)

        grid =
          for {line, y} <- Enum.with_index(charlists),
              {char, x} <- Enum.with_index(line),
              into: %{},
              do: {@dim_mod.new_coords(x, y), char}

        update(%T{empty_char: empty_char}, grid)
      end

      @doc "Creates a new #{@mod_short_name} from a list of {x, y} coordinates of non-empty cells."
      @spec from_coords_list(list({integer, integer}), char, char) :: t()
      def from_coords_list(coords_list, non_empty_char \\ ?#, empty_char \\ ?.) do
        grid =
          for {x, y} <- coords_list,
              into: %{},
              do: {@dim_mod.new_coords(x, y), non_empty_char}

        update(%T{empty_char: empty_char}, grid)
      end

      @doc "Gets the value at the given coordinates."
      @spec at(t(), coordinates) :: char
      def at(%T{} = t, coords) do
        Map.get(t.grid, coords, t.empty_char)
      end

      @doc """
      Applies `fun` to each cell in the #{@mod_short_name}
      to produce a new #{@mod_short_name}.
      """
      @spec map(t(), ({coordinates, char} -> char)) :: t()
      def map(%T{} = t, fun) do
        grid = for({coords, _} = entry <- t.grid, into: %{}, do: {coords, fun.(entry)})

        update(t, grid)
      end

      @doc """
      Returns the number of cells in the #{@mod_short_name} containing `char`.

      This returns `:infinity` when passed the #{@mod_short_name}'s empty char.
      """
      @spec count_chars(t(), char) :: non_neg_integer() | :infinity
      def count_chars(%T{empty_char: empty_char}, empty_char), do: :infinity

      def count_chars(%T{} = t, char) do
        Enum.count(t.grid, fn {_, c} -> c == char end)
      end

      @doc "Returns a list of values from the #{length(@adjacent_deltas)} cells adjacent to the one at `coords`."
      @spec adjacent_values(t(), coordinates) :: list(char)
      def adjacent_values(%T{} = t, coords) do
        @adjacent_deltas
        |> Enum.map(&@dim_mod.sum_coordinates(coords, &1))
        |> Enum.map(&at(t, &1))
      end

      defp update(t, grid) do
        bounds = get_bounds(grid, t.empty_char)

        %{t | grid: fill(grid, bounds, t.empty_char)}
      end

      defp get_bounds(grid, empty_char) do
        grid
        |> nonempty_coords(empty_char)
        |> Enum.reduce(&@dim_mod.min_maxer/2)
        |> @dim_mod.pad_ranges()
      end

      defp nonempty_coords(grid, empty_char) do
        for {coords, value} <- grid, not match?(^empty_char, value), do: coords
      end

      defp fill(grid, bounds, empty_char) do
        bounds
        |> @dim_mod.all_coords()
        |> Enum.reduce(grid, fn coords, g -> Map.put_new(g, coords, empty_char) end)
      end

      defp pad_range(l..r), do: (l - 1)..(r + 1)
    end
  end
end
