defmodule AdventOfCode.PriorityQueue do
  @moduledoc """
  Priority queue implementation.

  `pop` returns the element with the minimal value of `key_fn.(el)`.
  """
  @opaque t(a) :: %__MODULE__{
            data: [{key :: term, a}],
            key_fn: (a -> term)
          }
  @opaque t :: t(term)

  @default_key_fn &Function.identity/1

  defstruct key_fn: @default_key_fn, data: []

  @doc """
  Returns true if `q` is an empty priority queue.
  """
  defguard is_empty(q) when is_struct(q, __MODULE__) and q.data == []

  @doc """
  Creates a priority queue.
  """
  @spec new() :: t()
  @spec new((a -> term)) :: t(a) when a: var
  @spec new(Enumerable.t(a)) :: t(a) when a: var
  @spec new(Enumerable.t(a), (a -> term)) :: t(a) when a: var
  def new, do: %__MODULE__{}
  def new(key_fn) when is_function(key_fn, 1), do: %__MODULE__{key_fn: key_fn}
  def new(data), do: %__MODULE__{data: prepare_data(data, @default_key_fn)}

  def new(data, key_fn) when is_function(key_fn, 1) do
    %__MODULE__{key_fn: key_fn, data: prepare_data(data, key_fn)}
  end

  @doc """
  Inserts a new value into the priority queue.
  """
  @spec push(t(a), a) :: t(a) when a: var
  def push(%__MODULE__{} = q, el) do
    update_in(q.data, &do_push(&1, {q.key_fn.(el), el}))
  end

  @doc """
  If queue is not empty, returns:

      {:ok, highest_priority_element, rest_of_queue}

  If queue is empty, returns `:error`.
  """
  @spec pop(t(a)) :: {:ok, a, t(a)} | :error when a: var
  def pop(%__MODULE__{data: [{_key, el} | t]} = q), do: {:ok, el, %{q | data: t}}
  def pop(%__MODULE__{data: []}), do: :error

  @doc """
  Same as `pop/1`, but raises if queue is empty.
  """
  @spec pop!(t(a)) :: {a, t(a)} when a: var
  def pop!(%__MODULE__{data: [{_key, el} | t]} = q), do: {el, %{q | data: t}}
  def pop!(%__MODULE__{data: []}), do: raise("queue is empty")

  defp do_push(data, entry, acc \\ [])
  defp do_push([], entry, acc), do: Enum.reverse([entry | acc])

  defp do_push([{key2, _el2} | _] = l, {key, _el} = entry, acc) when key <= key2 do
    Enum.reverse([entry | acc]) ++ l
  end

  defp do_push([h | t], entry, acc) do
    do_push(t, entry, [h | acc])
  end

  defp prepare_data(data, key_fn) do
    data
    |> Enum.map(&{key_fn.(&1), &1})
    |> Enum.sort_by(fn {key, _} -> key end)
  end
end
