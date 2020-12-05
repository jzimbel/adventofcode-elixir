defmodule AdventOfCode.CharGrid do
  @moduledoc "Data structure representing a grid of characters by a map of {x, y} => char"

  @type t :: %__MODULE__{
          grid: grid,
          width: non_neg_integer,
          height: non_neg_integer
        }

  @typep grid :: %{coordinates => char}

  @type coordinates :: {non_neg_integer, non_neg_integer}

  @enforce_keys ~w[grid width height]a
  defstruct @enforce_keys

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

    %__MODULE__{
      grid: grid,
      width: width,
      height: height
    }
  end

  @spec at(t(), coordinates) :: char | nil
  def at(%__MODULE__{} = t, coords) do
    t.grid[coords]
  end
end
