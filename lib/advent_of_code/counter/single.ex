defmodule AdventOfCode.Counter.Single do
  @moduledoc """
  Set of macros that allow use of a multi-counter as if it were single.

  Use with `require AdventOfCode.Counter.Single[, as: <alias>]`.
  """

  @m AdventOfCode.Counter.Multi
  @k :k

  @doc """
  Starts a counter.

  Returns `{:ok, pid}` on success.

  Options:
  - `:value`: The counter is started with this value. If `reset/1` is called on it,
    it resets to this value. Defaults to 0.
  - `:natural`: If true, the counter's minimum value is 0.
    If false, it can go negative. Defaults to true.
  """
  defmacro start_link(opts \\ [], gen_server_opts \\ []) do
    quote bind_quoted: [opts: opts, gen_server_opts: gen_server_opts, k: @k, m: @m] do
      {value, opts} = Keyword.pop(opts, :value, 0)
      opts = Keyword.merge(opts, counts: %{k => value}, default_value: value)

      m.start_link(opts, gen_server_opts)
    end
  end

  @doc """
  Stops a counter process.
  """
  defmacro stop(counter, reason \\ :normal, timeout \\ :infinity) do
    quote bind_quoted: [counter: counter, reason: reason, timeout: timeout, m: @m] do
      m.stop(counter, reason, timeout)
    end
  end

  @doc """
  Returns the value of a counter.
  """
  defmacro value(counter) do
    quote bind_quoted: [counter: counter, k: @k, m: @m] do
      m.value(counter, k)
    end
  end

  @doc """
  Increases a counter by `n`.
  """
  defmacro add(counter, n) when is_integer(n) do
    quote bind_quoted: [counter: counter, n: n, k: @k, m: @m] do
      m.add(counter, k, n)
    end
  end

  @doc """
  Decreases a counter by `n`.
  """
  defmacro sub(counter, n) when is_integer(n) do
    quote bind_quoted: [counter: counter, n: n, k: @k, m: @m] do
      m.sub(counter, k, n)
    end
  end

  @doc """
  Increments a counter.
  """
  defmacro increment(counter) do
    quote bind_quoted: [counter: counter, k: @k, m: @m] do
      m.increment(counter, k)
    end
  end

  @doc """
  Decrements a counter.
  """
  defmacro decrement(counter) do
    quote bind_quoted: [counter: counter, k: @k, m: @m] do
      m.decrement(counter, k)
    end
  end

  @doc """
  Sets a counter to the given value.
  """
  defmacro set(counter, n) when is_integer(n) do
    quote bind_quoted: [counter: counter, n: n, k: @k, m: @m] do
      m.set(counter, k, n)
    end
  end

  @doc """
  Resets a counter to the value it was initialized with.
  """
  defmacro reset(counter) do
    quote bind_quoted: [counter: counter, k: @k, m: @m] do
      m.reset(counter, k)
    end
  end
end
