defmodule AdventOfCode.PriorityQueue do
  @moduledoc """
  Priority queue implementation.

  `pop` returns the element with the minimal value of `key_fn.(el)`.
  """

  @default_key_fn &Function.identity/1

  defstruct key_fn: @default_key_fn, data: []

  defguard is_empty(q) when is_struct(q, __MODULE__) and q.data == []

  def new, do: %__MODULE__{}
  def new(data) when is_list(data), do: %__MODULE__{data: prepare_data(data, @default_key_fn)}
  def new(key_fn) when is_function(key_fn, 1), do: %__MODULE__{key_fn: key_fn}

  def new(data, key_fn) when is_list(data) and is_function(key_fn, 1) do
    %__MODULE__{key_fn: key_fn, data: prepare_data(data, key_fn)}
  end

  def push(%__MODULE__{} = q, el) do
    update_in(q.data, &do_push(&1, {q.key_fn.(el), el}))
  end

  def pop(%__MODULE__{data: [{_key, el} | t]} = q), do: {:ok, el, %{q | data: t}}
  def pop(%__MODULE__{data: []}), do: :error

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
