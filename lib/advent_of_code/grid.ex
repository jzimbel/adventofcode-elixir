defmodule AdventOfCode.Grid do
  @moduledoc """
  Data structure representing a finite, dense, rectangular grid of values.

  Grid is represented by a map of {x, y} => value, where x and y are non-negative.

  The origin is the top-left corner of the grid. +x is "east"; +y is "south".
  """

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

  @type adjacency_type :: :all | :cardinal | :intercardinal | :up

  @type heading :: heading_name | heading_coords
  @type heading_name :: :n | :e | :s | :w | :ne | :se | :sw | :nw
  @type heading_coords :: {-1..1, -1 | 1} | {-1 | 1, -1..1}

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

  @doc """
  Creates a Grid whose cells all have the given value. (Default: ?.)

      iex> new(3, 3)
      #AdventOfCode.Grid<
        [width: 3, height: 3]
        ...
        ...
        ...
      >

      iex> new(5, 1, ?#)
      #AdventOfCode.Grid<
        [width: 5, height: 1]
        #####
      >
  """
  @spec new(non_neg_integer, non_neg_integer) :: t(char)
  @spec new(non_neg_integer, non_neg_integer, a) :: t(a) when a: var
  def new(width, height, fill_with \\ ?.) do
    grid =
      for x <- 0..(width - 1)//1, y <- 0..(height - 1)//1, into: %{} do
        {{x, y}, fill_with}
      end

    %T{
      grid: grid,
      width: width,
      height: height
    }
  end

  @doc """
  Creates a Grid from an AoC input string.

      iex> from_input(~S|
      ...> abc
      ...> def
      ...> ghi
      ...> |)
      #AdventOfCode.Grid<
        [width: 3, height: 3]
        abc
        def
        ghi
      >

      iex> from_input("")
      #AdventOfCode.Grid<
        [width: 0, height: 0]
      >

      iex> from_input(~S|
      ...> 123
      ...> 123
      ...> 1
      ...> |)
      ** (ArgumentError) `Grid.from_input`: inconsistent row lengths
  """
  @spec from_input(String.t()) :: t(char)
  @spec from_input(String.t(), (char -> a)) :: t(a) when a: var
  def from_input(input, mapper \\ &Function.identity/1)
  def from_input("", _mapper), do: %T{grid: %{}, width: 0, height: 0}

  def from_input(input, mapper) do
    charlists =
      input
      |> String.split()
      |> Enum.map(&String.to_charlist/1)

    height = length(charlists)
    width = length(hd(charlists))

    unless Enum.all?(charlists, &(length(&1) == width)) do
      raise ArgumentError, "`Grid.from_input`: inconsistent row lengths"
    end

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

  @doc ~S"""
  Creates a Grid from an Enumerable of cell values.

  By default, an exception will be raised if `cells` is sparse--that is, if it is
  missing one or more entries within the bounding box of x=0..max(x_coords), y=0..max(y_coords).

  Pass a 0-arity function as a second arg if you want missing entries to be filled
  in with a default value. E.g. `fn -> ?. end`.

      iex> from_cells([{{0,0}, ?A}, {{1,0}, ?B}, {{2,0}, ?C}])
      #AdventOfCode.Grid<
        [width: 3, height: 1]
        ABC
      >

      iex> from_cells([{{0,0}, ?A}, {{2,2}, ?Z}])
      ** (ArgumentError) `Grid.from_cells`: missing cells

      iex> from_cells([{{0,0}, ?A}, {{0,1}, ?#}, {{2,2}, ?Z}], fn -> ?. end)
      #AdventOfCode.Grid<
        [width: 3, height: 3]
        A..
        #..
        ..Z
      >

      iex> from_cells([])
      #AdventOfCode.Grid<
        [width: 0, height: 0]
      >
  """
  @spec from_cells(Enumerable.t(cell(a))) :: t(a) when a: var
  @spec from_cells(Enumerable.t(cell(a)), (-> a)) :: t(a) when a: var
  def from_cells(
        cells,
        default_fn \\ fn -> raise ArgumentError, "`Grid.from_cells`: missing cells" end
      ) do
    if Enum.empty?(cells) do
      %T{grid: %{}, width: 0, height: 0}
    else
      width = Stream.map(cells, &elem(elem(&1, 0), 0)) |> Enum.max() |> Kernel.+(1)
      height = Stream.map(cells, &elem(elem(&1, 0), 1)) |> Enum.max() |> Kernel.+(1)
      tentative_grid = Map.new(cells)

      grid =
        for x <- 0..(width - 1)//1,
            y <- 0..(height - 1)//1,
            into: %{} do
          {{x, y}, Map.get_lazy(tentative_grid, {x, y}, default_fn)}
        end

      %T{grid: grid, width: width, height: height}
    end
  end

  @doc """
  Creates a Grid from a list of lists of values.

  Each list within `cols` represents a column.
  `cols[0][0]` holds the value for cell `{0,0}`, `cols[3][1]` for cell `{3,1}`, and so on.

  You do not need to supply coordinates.
  Coordinates for each value are determined from its position within the 2D list.

      iex> from_cols([~c"A1.", ~c"B2-", ~c"C3^"])
      #AdventOfCode.Grid<
        [width: 3, height: 3]
        ABC
        123
        .-^
      >

      iex> from_cols([~c"123", ~c"1234", ~c"123"])
      ** (ArgumentError) `Grid.from_cols`: inconsistent column lengths
  """
  @spec from_cols(list(list(a))) :: t(a) when a: var
  def from_cols(cols) do
    width = length(cols)
    height = length(hd(cols))

    unless Enum.all?(cols, &(length(&1) == height)) do
      raise ArgumentError, "`Grid.from_cols`: inconsistent column lengths"
    end

    grid =
      for {col, x} <- Enum.with_index(cols),
          {value, y} <- Enum.with_index(col),
          into: %{},
          do: {{x, y}, value}

    %T{grid: grid, width: width, height: height}
  end

  @doc """
  Creates a Grid from a list of lists of values.

  Each list within `rows` represents a row.
  `rows[0][0]` holds the value for cell `{0,0}`, `rows[3][1]` for cell `{1,3}`, and so on.

  You do not need to supply coordinates.
  Coordinates for each value are determined from its position within the 2D list.

      iex> from_rows([~c"ABC", ~c"123", ~c".-^"])
      #AdventOfCode.Grid<
        [width: 3, height: 3]
        ABC
        123
        .-^
      >

      iex> from_rows([~c"123", ~c"1234", ~c"123"])
      ** (ArgumentError) `Grid.from_cols`: inconsistent row lengths
  """
  @spec from_rows(list(list(a))) :: t(a) when a: var
  def from_rows(rows) do
    width = length(hd(rows))
    height = length(rows)

    unless Enum.all?(rows, &(length(&1) == width)) do
      raise ArgumentError, "`Grid.from_cols`: inconsistent row lengths"
    end

    grid =
      for {row, y} <- Enum.with_index(rows),
          {value, x} <- Enum.with_index(row),
          into: %{},
          do: {{x, y}, value}

    %T{grid: grid, width: width, height: height}
  end

  @doc ~S"""
  Returns all cells in the grid, grouped into rows starting from the top.

      iex> rows(from_input("AB\nCD\n"))
      [[{{0,0}, ?A}, {{1,0}, ?B}], [{{0,1}, ?C}, {{1,1}, ?D}]]
  """
  @spec rows(t(a)) :: list(list(cell(a))) when a: var
  def rows(%T{} = t) do
    for y <- 0..(t.height - 1)//1 do
      for x <- 0..(t.width - 1)//1 do
        {{x, y}, t.grid[{x, y}]}
      end
    end
  end

  @doc ~S"""
  Returns all cells in the grid, grouped into columns starting from the left.

      iex> cols(from_input("AB\nCD\n"))
      [[{{0,0}, ?A}, {{0,1}, ?C}], [{{1,0}, ?B}, {{1,1}, ?D}]]
  """
  @spec cols(t(a)) :: list(list(cell(a))) when a: var
  def cols(%T{} = t) do
    for x <- 0..(t.width - 1)//1 do
      for y <- 0..(t.height - 1)//1 do
        {{x, y}, t.grid[{x, y}]}
      end
    end
  end

  @doc ~S"""
  Gets the value at the given coordinates.

      iex> grid = from_input("AB\nCD\n")
      iex> at(grid, {0,1})
      ?C
      iex> at(grid, {2,1})
      nil
  """
  @spec at(t(a), coordinates) :: a | nil when a: var
  @spec at(t(a), coordinates, default) :: a | default when a: var, default: var
  def at(%T{} = t, coords, default \\ nil) do
    Map.get(t.grid, coords, default)
  end

  @doc ~S"""
  Replaces the value of a cell.

      iex> grid = from_input("AB\nCD\n")
      iex> replace(grid, {0,0}, ?X)
      #AdventOfCode.Grid<
        [width: 2, height: 2]
        XB
        CD
      >
      iex> replace(grid, {2,0}, ?X)
      ** (KeyError) key {2, 0} not found
  """
  @spec replace(t(a), coordinates, a) :: t(a) when a: var
  def replace(%T{} = t, coords, value) do
    %{t | grid: %{t.grid | coords => value}}
  end

  @doc """
  Replaces 0 or more cell values.

      iex> grid = from_input(~S|
      ...> abc
      ...> def
      ...> ghi
      ...> |)
      iex> replace_many(grid, %{{0,0} => ?X, {2,0} => ?Y, {0,2} => ?Z})
      #AdventOfCode.Grid<
        [width: 3, height: 3]
        XbY
        def
        Zhi
      >
  """
  @spec replace_many(t(a), grid(a)) :: t(a) when a: var
  def replace_many(%T{} = t, cells) do
    valid = Map.intersect(t.grid, cells)

    if map_size(valid) != map_size(cells) do
      extraneous = Map.drop(cells, Map.keys(t.grid))

      IO.warn(
        "replacement map contains extraneous cell(s), which will be ignored: #{inspect(extraneous)}"
      )
    end

    %{t | grid: Map.merge(t.grid, valid)}
  end

  @doc ~S"""
  Updates the value of a cell.

      iex> grid = from_input("AB\nCD\n")
      iex> update(grid, {1,1}, fn char -> char + 1 end)
      #AdventOfCode.Grid<
        [width: 2, height: 2]
        AB
        CE
      >
      iex> update(grid, {2,0}, fn char -> char + 1 end)
      ** (KeyError) key {2, 0} not found in: %{{0, 0} => 65, {0, 1} => 67, {1, 0} => 66, {1, 1} => 68}
  """
  @spec update(t(a), coordinates, (a -> a)) :: t(a) when a: var
  def update(%T{} = t, coords, updater_fn) do
    %{t | grid: Map.update!(t.grid, coords, updater_fn)}
  end

  @doc ~S"""
  Swaps the values of the cells with the two given coordinate pairs.

      iex> grid = from_input("AB\nCD\n")
      iex> swap_cells(grid, {0,0}, {1,1})
      #AdventOfCode.Grid<
        [width: 2, height: 2]
        DB
        CA
      >
      iex> swap_cells(grid, {0,0}, {2,0})
      ** (KeyError) key {2, 0} not found
  """
  @spec swap_cells(t(a), coordinates, coordinates) :: t(a) when a: var
  def swap_cells(%T{} = t, coords1, coords2) do
    update_in(t.grid, &%{&1 | coords1 => &1[coords2], coords2 => &1[coords1]})
  end

  @doc ~S"""
  Applies `fun` to each cell to produce a new Grid.

      iex> grid = from_input("AB\nCD\n")
      iex> map(grid, fn {_coords, char} -> char + 1 end)
      #AdventOfCode.Grid<
        [width: 2, height: 2]
        BC
        DE
      >
  """
  @spec map(t(a), (cell(a) -> b)) :: t(b) when a: var, b: var
  def map(%T{} = t, fun) do
    %{t | grid: Map.new(t.grid, fn {coords, _} = cell -> {coords, fun.(cell)} end)}
  end

  @doc ~S"""
  Converts the grid to a list of cells. Order is unspecified.

    iex> grid = from_input("AB\nCD\n")
    iex> to_list(grid) |> Enum.all?(&match?({{_x, _y}, _char}, &1))
    true
  """
  @spec to_list(t(a)) :: list(cell(a)) when a: var
  def to_list(%T{} = t) do
    Map.to_list(t.grid)
  end

  @doc ~S"""
  Returns the number of cells for which `predicate` returns a truthy value.

      iex> grid = from_input("AB\nCD\n")
      iex> count(grid, fn {_coords, char} -> char > ?B end)
      2
  """
  @spec count(t(a), (cell(a) -> as_boolean(any()))) :: non_neg_integer() when a: var
  def count(%T{} = t, predicate) do
    Enum.count(t.grid, predicate)
  end

  @doc ~S"""
  Returns the number of cells containing `value`.

      iex> grid = from_input("#..\n.#.\n..#\n")
      iex> count_values(grid, ?.)
      6
  """
  @spec count_values(t(term), term) :: non_neg_integer()
  def count_values(%T{} = t, value) do
    count(t, &match?({_, ^value}, &1))
  end

  @type cell_pred(a) :: (cell(a) -> as_boolean(any()))

  @doc ~S"""
  Returns a list of cells for which `predicate` returns a truthy value.

  Order of the returned list is unspecified.

      iex> grid = from_input("AB\nCD\n")
      iex> cells = filter_cells(grid, fn {_coords, char} -> char > ?B end)
      iex> Enum.sort(cells)
      [{{0,1}, ?C}, {{1,1}, ?D}]
  """
  @spec filter_cells(t(a), cell_pred(a)) :: list(cell(a)) when a: var
  def filter_cells(%T{} = t, predicate) do
    Enum.filter(t.grid, predicate)
  end

  @doc ~S"""
  Returns the first cell for which `predicate` returns a truthy value, or nil if none is found.

  If you need to search the grid in a particular order, pass the
  appropriate value as the third argument.

  Keep in mind that specifying a search order forces a sort of the entire grid.
  It may be more efficient to use `filter_cells` + `Enum.sort(...)` + `Enum.at(0)` instead.

  - `:unspecified` - Search order doesn't matter (default)
  - `:columnar` - Search down each column, from left to right
  - `:row_wise` - Search across each row, from top to bottom
  - a 1-arity fn - The fn will be passed to `Enum.sort_by` for custom sort order by key.
  - a 2-arity fn - The fn will be passed to `Enum.sort` for custom sort order by comparison.

  ## Examples

      iex> grid = from_input("..\n*.\n")
      iex> find_cell(grid, &match?({_coords, ?*}, &1))
      {{0,1}, ?*}

      iex> grid = from_input(".*\n**\n")
      iex> predicate = &match?({_coords, ?*}, &1)
      iex> find_cell(grid, predicate, :columnar)
      {{0,1}, ?*}
      iex> find_cell(grid, predicate, :row_wise)
      {{1,0}, ?*}
      iex> find_cell(grid, predicate, fn {{x, y}, _} -> {-x, -y} end)
      {{1,1}, ?*}
  """
  @spec find_cell(t(a), cell_pred(a)) :: cell(a) | nil when a: var
  @spec find_cell(t(a), cell_pred(a), atom) :: cell(a) | nil when a: var
  @spec find_cell(t(a), cell_pred(a), (cell(a) -> any)) :: cell(a) | nil when a: var
  @spec find_cell(t(a), cell_pred(a), (cell(a), cell(a) -> boolean)) :: cell(a) | nil when a: var
  def find_cell(%T{} = t, predicate, search_order \\ :unspecified) do
    case search_order do
      :unspecified -> Enum.find(t.grid, predicate)
      :columnar -> t.grid |> Enum.sort() |> Enum.find(predicate)
      :row_wise -> t.grid |> Enum.sort_by(fn {{x, y}, _} -> {y, x} end) |> Enum.find(predicate)
      key_fn when is_function(key_fn, 1) -> t.grid |> Enum.sort_by(key_fn) |> Enum.find(predicate)
      cmp_fn? when is_function(cmp_fn?, 2) -> t.grid |> Enum.sort(cmp_fn?) |> Enum.find(predicate)
    end
  end

  @doc """
  Returns the cell adjacent to `coords` in `heading` direction,
  or nil if no such cell exists.

      iex> grid = from_input(~S|
      ...> FN7
      ...> W*E
      ...> LSJ
      ...> |)
      iex> adjacent_cell(grid, {1,1}, :e)
      {{2,1}, ?E}
      iex> adjacent_cell(grid, {1,1}, {0,1})
      {{1,2}, ?S}
      iex> adjacent_cell(grid, {0,0}, :nw)
      nil
  """
  @spec adjacent_cell(t(a), coordinates, heading) :: cell(a) | nil when a: var
  def adjacent_cell(%T{} = t, coords, heading) do
    adj_coords = sum_coordinates(coords, normalize_heading(heading))

    case at(t, adj_coords) do
      nil -> nil
      v -> {adj_coords, v}
    end
  end

  @doc """
  Returns a list of cells adjacent to the one at `coords`.

  By default (when `in_bounds_only?` is true), if a cell in a particular
  direction doesn't exist because the starting cell is on the edge of the grid,
  a shorter list is returned.

  If `in_bounds_only?` is false, cells of the form `{coordinates, nil}` will
  be included in the returned list for out-of-bounds adjacent locations.

  The type of adjacency is determined by the third argument:

  `:all` (default behavior):\
  Order returned: `[nw, w, sw, n, s, ne, e, se]`

      OOO
      O*O
      OOO

  `:cardinal`:\
  Order returned: `[w, n, s, e]`

      .O.
      O*O
      .O.

  `:intercardinal`:\
  Order returned: `[nw, sw, ne, se]`

      O.O
      .*.
      O.O

  ## Examples

      iex> grid = from_input(~S|
      ...> FN7
      ...> W*E
      ...> LSJ
      ...> |)
      iex> adjacent_cells(grid, {1,1})
      [
        {{0,0}, ?F}, {{0,1}, ?W}, {{0,2}, ?L},
        {{1,0}, ?N},              {{1,2}, ?S},
        {{2,0}, ?7}, {{2,1}, ?E}, {{2,2}, ?J}
      ]
      iex> adjacent_cells(grid, {0,0})
      [{{0,1}, ?W}, {{1,0}, ?N}, {{1,1}, ?*}]
      iex> adjacent_cells(grid, {1,1}, :cardinal)
      [{{0,1}, ?W}, {{1,0}, ?N}, {{1,2}, ?S}, {{2,1}, ?E}]
      iex> adjacent_cells(grid, {1,1}, :intercardinal)
      [{{0,0}, ?F}, {{0,2}, ?L}, {{2,0}, ?7}, {{2,2}, ?J}]
      iex> adjacent_cells(grid, {0,0}, :cardinal, false)
      [{{-1,0}, nil}, {{0,-1}, nil}, {{0,1}, ?W}, {{1,0}, ?N}]
  """
  @spec adjacent_cells(t(a), coordinates, adjacency_type, boolean) :: list(cell(a)) when a: var
  def adjacent_cells(%T{} = t, coords, adjacency_type \\ :all, in_bounds_only? \\ true) do
    @adjacency_deltas_by_type[adjacency_type]
    |> Enum.map(&sum_coordinates(coords, &1))
    |> Enum.map(fn adjacent_coords -> {adjacent_coords, at(t, adjacent_coords)} end)
    |> then(fn cells ->
      if in_bounds_only? do
        Enum.reject(cells, fn {_coords, value} -> is_nil(value) end)
      else
        cells
      end
    end)
  end

  @doc """
  Convenience function that behaves the same as `adjacent_cells/3`,
  but returns only the value of each adjacent cell.
  """
  @spec adjacent_values(t(a), coordinates, adjacency_type, boolean) :: list(a) when a: var
  def adjacent_values(%T{} = t, coords, adjacency_type \\ :all, in_bounds_only? \\ true) do
    t
    |> adjacent_cells(coords, adjacency_type, in_bounds_only?)
    |> Enum.map(&elem(&1, 1))
  end

  @doc """
  Convenience function that behaves the same as `adjacent_cells/3`,
  but returns only the coordinates of each adjacent cell.
  """
  @spec adjacent_coords(t(term), coordinates, adjacency_type, boolean) :: list(coordinates)
  def adjacent_coords(t, coords, adjacency_type \\ :all, in_bounds_only? \\ true)

  def adjacent_coords(%T{} = t, coords, adjacency_type, true) do
    t
    |> adjacent_cells(coords, adjacency_type, true)
    |> Enum.map(&elem(&1, 0))
  end

  # We don't actually need to do any map lookups on the grid in this case.
  # (Maybe this function should be moved to a different module?)
  def adjacent_coords(_t, coords, adjacency_type, false) do
    @adjacency_deltas_by_type[adjacency_type]
    |> Enum.map(&sum_coordinates(coords, &1))
  end

  @doc """
  Returns a list of cells in a line from the one at `coords`.
  The list starts with the cell nearest `coords`, and extends away from it.

  If `lazy?` is true, a stream will be returned instead.

      iex> grid = from_input(~S|
      ...> 168ac
      ...> 2FN7d
      ...> 3W*Ee
      ...> 4LSJf
      ...> 579bg
      ...> |)
      iex> line_of_cells(grid, {2,2}, :ne)
      [{{3,1}, ?7}, {{4,0}, ?c}]
      iex> line_of_cells(grid, {0,0}, :nw)
      []
      iex> line_of_cells(grid, {2,2}, {1, -1})
      [{{3,1}, ?7}, {{4,0}, ?c}]
  """
  @spec line_of_cells(t(a), coordinates, heading, false) :: list(cell(a))
        when a: var
  @spec line_of_cells(t(a), coordinates, heading, true) :: Enumerable.t(cell(a))
        when a: var
  def line_of_cells(%T{} = t, coords, heading, lazy? \\ false) do
    step = normalize_heading(heading)
    get_line_of_cells(t, step, sum_coordinates(coords, step), lazy?)
  end

  @doc """
  Returns a list of lists of cells in lines from the one at `coords`.

  Each list starts with the cell nearest `coords`, and radiates outward
  until it hits the edge of the grid.

  If `lazy?` is true, a list of **streams** will be returned instead.

  The type of adjacency is determined by the third argument:

  `:all` (default behavior):

      O.O.O
      .OOO.
      OO*OO
      .OOO.
      O.O.O

  `:cardinal`:

      ..O..
      ..O..
      OO*OO
      ..O..
      ..O..

  `:intercardinal`:

      O...O
      .O.O.
      ..*..
      .O.O.
      O...O

      iex> grid = from_input(~S|
      ...> 168ac
      ...> 2FN7d
      ...> 3W*Ee
      ...> 4LSJf
      ...> 579bg
      ...> |)
      iex> lines_of_cells(grid, {2,2})
      [
        [{{1,1}, ?F}, {{0,0}, ?1}],
        [{{1,2}, ?W}, {{0,2}, ?3}],
        [{{1,3}, ?L}, {{0,4}, ?5}],
        [{{2,1}, ?N}, {{2,0}, ?8}],
        [{{2,3}, ?S}, {{2,4}, ?9}],
        [{{3,1}, ?7}, {{4,0}, ?c}],
        [{{3,2}, ?E}, {{4,2}, ?e}],
        [{{3,3}, ?J}, {{4,4}, ?g}]
      ]
      iex> lines_of_cells(grid, {0,0})
      [
        _nw = [],
        _w  = [],
        _sw = [],
        _n  = [],
        [{{0,1}, ?2}, {{0,2}, ?3}, {{0,3}, ?4}, {{0,4}, ?5}],
        _ne = [],
        [{{1,0}, ?6}, {{2,0}, ?8}, {{3,0}, ?a}, {{4,0}, ?c}],
        [{{1,1}, ?F}, {{2,2}, ?*}, {{3,3}, ?J}, {{4,4}, ?g}]
      ]
      iex> lines_of_cells(grid, {0,0}, :intercardinal)
      [
        _nw = [],
        _sw = [],
        _ne = [],
        [{{1,1}, ?F}, {{2,2}, ?*}, {{3,3}, ?J}, {{4,4}, ?g}]
      ]
  """
  @spec lines_of_cells(t(a), coordinates, adjacency_type, false) :: [[cell(a)]] when a: var
  @spec lines_of_cells(t(a), coordinates, adjacency_type, true) :: [Enumerable.t(cell(a))]
        when a: var
  def lines_of_cells(%T{} = t, coords, adjacency_type \\ :all, lazy? \\ false) do
    @adjacency_deltas_by_type[adjacency_type]
    |> Enum.map(&get_line_of_cells(t, &1, sum_coordinates(coords, &1), lazy?))
  end

  @doc """
  Convenience function that behaves the same as `lines_of_cells/3`,
  but returns only the value of each cell.

      iex> grid = from_input(~S|
      ...> 168ac
      ...> 2FN7d
      ...> 3W*Ee
      ...> 4LSJf
      ...> 579bg
      ...> |)
      iex> lines_of_values(grid, {2,2})
      [~c"F1", ~c"W3", ~c"L5", ~c"N8", ~c"S9", ~c"7c", ~c"Ee", ~c"Jg"]
      iex> lines_of_values(grid, {0,0})
      [[], [], [], [], ~c"2345", _ne = [], ~c"68ac", ~c"F*Jg"]
      iex> lines_of_values(grid, {0,0}, :intercardinal)
      [[], [], [], ~c"F*Jg"]
  """
  @spec lines_of_values(t(a), coordinates, adjacency_type, false) :: [[a]] when a: var
  @spec lines_of_values(t(a), coordinates, adjacency_type, true) :: [Enumerable.t(a)] when a: var
  def lines_of_values(%T{} = t, coords, adjacency_type \\ :all, lazy? \\ false) do
    mapper = if lazy?, do: &Stream.map/2, else: &Enum.map/2

    t
    |> lines_of_cells(coords, adjacency_type, lazy?)
    |> Enum.map(fn line -> mapper.(line, &elem(&1, 1)) end)
  end

  @doc """
  Convenience function that behaves the same as `lines_of_cells/3`,
  but returns only the coordinates of each cell.
  """
  @spec lines_of_coords(t(), coordinates, adjacency_type, false) :: [[coordinates]]
  @spec lines_of_coords(t(), coordinates, adjacency_type, true) :: [Enumerable.t(coordinates)]
  def lines_of_coords(%T{} = t, coords, adjacency_type \\ :all, lazy? \\ false) do
    mapper = if lazy?, do: &Stream.map/2, else: &Enum.map/2

    t
    |> lines_of_cells(coords, adjacency_type, lazy?)
    |> Enum.map(fn line -> mapper.(line, &elem(&1, 0)) end)
  end

  @doc """
  Returns a list of values from the up to 8 occupied cells reachable by a chess queen's move from the
  cell at `coords`.

  The optional `empty_value` (default `?.`) dictates which cells are considered unoccupied.

      iex> grid = from_input(~S|
      ...> Q..BX
      ...> ....X
      ...> .X...
      ...> .....
      ...> A..X.
      ...> |)
      iex> queen_move_values(grid, {0,0})
      [?A, ?B]
  """
  @spec queen_move_values(t(a), coordinates, a) :: list(a) when a: var
  def queen_move_values(%T{} = t, coords, empty_value \\ ?.) do
    lines_of_values(t, coords, :all, true)
    |> Enum.map(fn line -> Enum.find(line, &(&1 != empty_value)) end)
    |> Enum.reject(&is_nil/1)
  end

  @doc ~S"""
  Returns true if `coords` exists within the grid.

      iex> grid = from_input("AB\nCD\n")
      iex> in_bounds?(grid, {0,1})
      true
      iex> in_bounds?(grid, {8,1})
      false
      iex> in_bounds?(grid, {-1,-1})
      false
  """
  @spec in_bounds?(t(), any) :: boolean
  def in_bounds?(%T{} = t, coords) do
    Map.has_key?(t.grid, coords)
  end

  @doc """
  Translates a "step" tuple to a compass direction.

  Examples:

      iex> heading_to_compass({-1,1})
      "sw"
      iex> heading_to_compass({1,0})
      "e"
  """
  @spec heading_to_compass(heading_coords) :: String.t()
  def heading_to_compass({x, y}) do
    "#{Enum.at(["n", "", "s"], y + 1)}#{Enum.at(["w", "", "e"], x + 1)}"
  end

  @doc """
  Sums two coordinate pairs together.

      iex> sum_coordinates({3,5}, {1,1})
      {4,6}
  """
  def sum_coordinates({x1, y1}, {x2, y2})
      when is_integer(x1) and is_integer(y1) and is_integer(x2) and is_integer(y2),
      do: {x1 + x2, y1 + y2}

  defp get_line_of_cells(t, step, coords, lazy? \\ false)

  defp get_line_of_cells(t, step, coords, false) do
    case at(t, coords) do
      nil -> []
      val -> [{coords, val} | get_line_of_cells(t, step, sum_coordinates(coords, step))]
    end
  end

  defp get_line_of_cells(t, step, coords, true) do
    Stream.unfold(
      coords,
      &case at(t, &1) do
        nil -> nil
        val -> {{&1, val}, sum_coordinates(&1, step)}
      end
    )
  end

  defp normalize_heading(name) when is_atom(name) do
    case name do
      :n -> {0, -1}
      :ne -> {1, -1}
      :e -> {1, 0}
      :se -> {1, 1}
      :s -> {0, 1}
      :sw -> {-1, 1}
      :w -> {-1, 0}
      :nw -> {-1, -1}
    end
  end

  defp normalize_heading({x, y} = heading)
       when (x in -1..1 and y in -1..1 and x != 0) or y != 0 do
    heading
  end
end

defimpl Enumerable, for: AdventOfCode.Grid do
  def count(grid), do: Enumerable.Map.count(grid.grid)
  def member?(grid, element), do: Enumerable.Map.member?(grid.grid, element)
  def reduce(grid, acc, fun), do: Enumerable.Map.reduce(grid.grid, acc, fun)
  def slice(grid), do: Enumerable.Map.slice(grid.grid)
end

defimpl Collectable, for: AdventOfCode.Grid do
  def into(grid), do: {grid, &collect/2}

  defp collect(grid_acc, {:cont, {coords, value}}) when is_map_key(grid_acc.grid, coords) do
    put_in(grid_acc.grid[coords], value)
  end

  defp collect(_grid_acc, {:cont, other}) do
    raise ArgumentError,
          "collecting into a Grid requires {key, value} tuples where key is " <>
            "a coordinate pair within the bounds of the grid, got: #{inspect(other)}"
  end

  defp collect(grid_acc, :done), do: grid_acc

  defp collect(_, :halt), do: :ok
end

# Inspect and String.Chars implementations assume the grid has char-valued cells.
# Trying to inspect or stringify a grid with values that do not implement String.Chars will fail.

defimpl Inspect, for: AdventOfCode.Grid do
  import Inspect.Algebra

  def inspect(grid, opts) do
    contents =
      if match?(%{width: 0, height: 0}, grid) do
        empty()
      else
        concat(
          line(),
          concat(
            grid
            |> @for.rows()
            |> Enum.map_intersperse(line(), &to_string(for({_coords, char} <- &1, do: char)))
          )
        )
      end

    line(
      nest(
        concat([
          group(concat(["#", Inspect.Atom.inspect(@for, opts), "<"])),
          line(),
          Inspect.List.inspect([width: grid.width, height: grid.height], opts),
          contents
        ]),
        2
      ),
      ">"
    )
  end
end

defimpl String.Chars, for: AdventOfCode.Grid do
  def to_string(grid) do
    grid
    |> @for.rows()
    |> Enum.map_join("\n", &for({_, char} <- &1, do: char))
  end
end
