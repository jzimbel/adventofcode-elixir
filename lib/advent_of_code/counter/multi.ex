defmodule AdventOfCode.Counter.Multi do
  @moduledoc """
  Process that keeps counts.
  """
  use GenServer

  @type t :: %__MODULE__{
          counts: %{term => integer},
          default_value: integer,
          natural: boolean
        }

  @enforce_keys [:counts, :default_value, :natural]
  defstruct @enforce_keys

  @default_opts counts: %{}, default_value: 0, natural: true

  @doc """
  Starts a counter.

  Returns `{:ok, pid}` on success.

  Options:
  - `:counts`: A map of initial counts. Defaults to an empty map.
  - `:default_value`: Value to initialize/reset counters to. Defaults to 0.
  - `:natural`: If true, the counter's minimum value is 0.
    If false, it can go negative. Defaults to true.
  """
  def start_link(opts \\ [], gen_server_opts \\ []) do
    {opts, invalid} = Keyword.split(opts, [:counts, :default_value, :natural])
    opts = Keyword.merge(opts, @default_opts, fn _, v, _ -> v end)

    with :ok <- validate(opts, invalid) do
      GenServer.start_link(__MODULE__, opts, gen_server_opts)
    end
  end

  def stop(counter, reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(counter, reason, timeout)
  end

  def value(counter, key), do: GenServer.call(counter, {:value, key})
  def values(counter), do: GenServer.call(counter, :values)

  def add(counter, key, n) when is_integer(n) do
    GenServer.cast(counter, {:add, key, n})
  end

  def sub(counter, key, n) when is_integer(n) do
    GenServer.cast(counter, {:add, key, -n})
  end

  def increment(counter, key), do: GenServer.cast(counter, {:add, key, 1})
  def decrement(counter, key), do: GenServer.cast(counter, {:add, key, -1})

  @doc """
  Initializes count(s) under the given key or keys with the default value.
  If any count already exists, it's left unchanged.
  """
  def touch(counter, [_ | _] = keys), do: GenServer.cast(counter, {:touch, keys})
  def touch(counter, key), do: touch(counter, [key])

  def set(counter, key, n) when is_integer(n) do
    GenServer.cast(counter, {:set, key, n})
  end

  @doc """
  Sets all existing counters to `n`.
  (Any counters added later will still start at the default value.)
  """
  def set_all(counter, n) when is_integer(n), do: GenServer.cast(counter, {:set, n})

  @doc """
  Resets the count under the given key to the default value.
  If a count with the given key doesn't exist, this makes no change.
  """
  def reset(counter, key), do: GenServer.cast(counter, {:reset, key})
  def reset_all(counter), do: GenServer.cast(counter, :reset)

  defp validate(opts, []) do
    cond do
      not is_map(opts[:counts]) ->
        {:error, ":counts must be a map"}

      Enum.any?(opts[:counts], fn {_, v} -> not is_integer(v) end) ->
        {:error, ":counts map must have only integer values"}

      not is_integer(opts[:default_value]) ->
        {:error, ":default_value must be an integer"}

      not is_boolean(opts[:natural]) ->
        {:error, ":natural must be a boolean"}

      opts[:natural] and Enum.any?(opts[:counts], fn {_, v} -> v < 0 end) ->
        {:error, ":counts map must have only non-neg values when :natural is true"}

      opts[:natural] and opts[:default_value] < 0 ->
        {:error, ":default_value must be non-neg when :natural is true"}

      true ->
        :ok
    end
  end

  defp validate(_, invalid) do
    {:error,
     "invalid init option(s) passed to #{inspect(__MODULE__)}: #{inspect(Keyword.keys(invalid))}"}
  end

  ###

  @impl true
  def init(opts) do
    {:ok,
     %__MODULE__{
       counts: opts[:counts],
       default_value: opts[:default_value],
       natural: opts[:natural]
     }}
  end

  @impl true
  def handle_call({:value, k}, _from, state) do
    {:reply, state.counts[k], state}
  end

  def handle_call(:values, _from, state) do
    {:reply, state.counts, state}
  end

  def handle_cast({:add, k, n}, %{natural: true} = state) do
    %{counts: counts, default_value: dv} = state
    {:noreply, %{state | counts: Map.update(counts, k, dv + n, &max(&1 + n, 0))}}
  end

  @impl true
  def handle_cast({:add, k, n}, %{counts: counts, default_value: dv} = state) do
    {:noreply, %{state | counts: Map.update(counts, k, dv + n, &(&1 + n))}}
  end

  def handle_cast({:touch, ks}, %{default_value: dv} = state) do
    updater = Map.new(ks, &{&1, dv})
    {:noreply, update_in(state.counts, fn m -> Map.merge(m, updater, fn _, v, _ -> v end) end)}
  end

  def handle_cast({:set, k, n}, %{natural: true}) when n < 0 do
    id =
      case GenServer.whereis(self()) do
        {name, _node} -> name
        pid -> pid
      end

    msg =
      "can't set natural counter value to a negative: #{n} (counter: #{inspect(id)}, key: #{inspect(k)})"

    raise ArgumentError, msg
  end

  def handle_cast({:set, k, n}, state) do
    {:noreply, put_in(state.counts[k], n)}
  end

  def handle_cast({:set, n}, %{natural: true}) when n < 0 do
    id =
      case GenServer.whereis(self()) do
        {name, _node} -> name
        pid -> pid
      end

    msg = "can't set natural counter values to a negative: #{n} (counter: #{inspect(id)})"

    raise ArgumentError, msg
  end

  def handle_cast({:set, n}, state) do
    {:noreply, update_in(state.counts, fn m -> Map.new(m, fn {k, _} -> {k, n} end) end)}
  end

  def handle_cast({:reset, k}, %{default_value: dv} = state) do
    {:noreply, update_in(state.counts, &Map.replace(&1, k, dv))}
  end

  def handle_cast(:reset, %{default_value: dv} = state) do
    {:noreply, update_in(state.counts, fn m -> Map.new(m, fn {k, _} -> {k, dv} end) end)}
  end
end
