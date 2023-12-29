# Using a bunch of processes was completely unnecessary for this puzzle,
# since it requires a global message order which turns almost everything
# into sequential operations and defeats the purpose.
#
# But this works.
# It's also safe to run multiple times concurrently since it uses no named processes.
# (Tho it doesn't clean up after itself--processes aren't stopped.)
defmodule AdventOfCode.Solution.Year2023.Day20 do
  alias AdventOfCode.Counter.Multi, as: Counter
  alias AdventOfCode.Math

  defprotocol BoxBehavior do
    @spec handle_pulse(t(), boolean, pid) :: {t(), :pulse, boolean} | {t(), :no_pulse}
    def handle_pulse(t, pulse, from)

    @spec set_input_count(t(), non_neg_integer) :: t()
    def set_input_count(t, count)
  end

  defmodule Broadcaster, do: defstruct([])
  defmodule FlipFlop, do: defstruct(state: false)
  defmodule Conjunction, do: defstruct(state: %{}, input_count: 0)
  defmodule Button, do: defstruct([])

  defimpl BoxBehavior, for: Broadcaster do
    def handle_pulse(t, pulse, _), do: {t, :pulse, pulse}
    def set_input_count(t, _), do: t
  end

  defimpl BoxBehavior, for: FlipFlop do
    def handle_pulse(t, true, _), do: {t, :no_pulse}
    def handle_pulse(t, false, _), do: {%{t | state: not t.state}, :pulse, not t.state}
    def set_input_count(t, _), do: t
  end

  defimpl BoxBehavior, for: Conjunction do
    def handle_pulse(t, pulse, from) do
      t = update_in(t.state, &Map.put(&1, from, pulse))
      any_lo = map_size(t.state) < t.input_count or Enum.any?(Map.values(t.state), &(not &1))

      {t, :pulse, any_lo}
    end

    def set_input_count(t, count), do: %{t | input_count: count}
  end

  defimpl BoxBehavior, for: Button do
    def handle_pulse(t, _, _), do: {t, :pulse, false}
    def set_input_count(t, _), do: t
  end

  defmodule BoxAgent do
    @type t :: %__MODULE__{
            label: String.t(),
            impl: BoxBehavior.t(),
            counter: pid,
            history: pid,
            outputs: list(pid)
          }

    @enforce_keys [:label, :impl, :counter, :history]
    defstruct @enforce_keys ++ [outputs: []]

    def start_link(impl, counter, history, label) do
      Agent.start_link(fn ->
        %__MODULE__{label: label, impl: struct(impl), counter: counter, history: history}
      end)
    end

    def set_outputs(box, outputs) do
      Agent.update(box, __MODULE__, :handle_set_outputs, [outputs])
    end

    def set_input_count(box, count) do
      Agent.update(box, __MODULE__, :handle_set_intput_count, [count])
    end

    def send_pulse(box, pulse, from, n) do
      Agent.get_and_update(box, __MODULE__, :handle_send_pulse, [pulse, from, n])
    end

    def handle_set_outputs(state, outputs) do
      %{state | outputs: outputs}
    end

    def handle_set_intput_count(state, count) do
      update_in(state.impl, &BoxBehavior.set_input_count(&1, count))
    end

    def handle_send_pulse(state, pulse, from, n) do
      case BoxBehavior.handle_pulse(state.impl, pulse, from) do
        {%Conjunction{} = impl, :pulse, true = new_pulse} ->
          Agent.cast(state.history, Map, :update, [state.label, [n], fn ns -> ns ++ [n] end])
          Counter.add(state.counter, new_pulse, length(state.outputs))
          {{:pulse, new_pulse, self(), state.outputs}, put_in(state.impl, impl)}

        {impl, :pulse, new_pulse} ->
          Counter.add(state.counter, new_pulse, length(state.outputs))
          {{:pulse, new_pulse, self(), state.outputs}, put_in(state.impl, impl)}

        {impl, :no_pulse} ->
          {:no_pulse, put_in(state.impl, impl)}
      end
    end
  end

  ###############
  # MAIN MODULE #
  ###############

  def part1(input) do
    {init_pulse, counter, _, _} = setup(input)

    Stream.repeatedly(fn -> propagate_pulses([init_pulse], 0) end)
    |> Stream.take(1000)
    |> Stream.run()

    %{true: hi_count, false: lo_count} = Counter.values(counter)

    hi_count * lo_count
  end

  def part2(input) do
    # My code assumes the puzzle input has a layout of
    #   [conj_1, ..., conj_n] -> final_conj -> rx
    # and finds [conj_1, ..., conj_n], as `input_conjunctions`.
    # final_conj will only output lo when all its inputs are hi,
    # so I find cycles of hi pulse output cycles in conj_1, ...,
    # and then find lcm of all those cycles.
    #
    # This might not work for everyone's puzzle inputs.
    {init_pulse, _, history, input_conjunctions} = setup(input)

    Stream.iterate(1, &(&1 + 1))
    |> Stream.each(&propagate_pulses([init_pulse], &1))
    |> Stream.map(fn _ -> Agent.get(history, Map, :take, [input_conjunctions]) end)
    |> Stream.filter(&(map_size(&1) > 0))
    |> Stream.map(&Map.values/1)
    |> Enum.find(fn cycles -> Enum.all?(cycles, &match?([_, _ | _], &1)) end)
    |> Enum.map(fn [hi_pulse_t1, hi_pulse_t2 | _] -> hi_pulse_t2 - hi_pulse_t1 end)
    |> Math.lcm()
  end

  defp propagate_pulses([], _n), do: :ok

  defp propagate_pulses(pulses, n) do
    pulses
    |> Enum.flat_map(&send_pulse(&1, n))
    |> propagate_pulses(n)
  end

  defp send_pulse({pulse, from_pid, to_pids}, n) do
    to_pids
    |> Stream.map(&BoxAgent.send_pulse(&1, pulse, from_pid, n))
    |> Stream.reject(&(&1 == :no_pulse))
    |> Stream.map(fn {:pulse, pulse, from_pid, to_pids} -> {pulse, from_pid, to_pids} end)
  end

  defp setup(input) do
    {:ok, counter} = Counter.start_link(counts: %{true: 0, false: 0})
    {:ok, history} = Agent.start_link(fn -> %{} end)
    {:ok, button} = BoxAgent.start_link(Button, counter, history, "button")

    # 2-stage initialization:
    # 1st pass starts all box agents listed on lhs
    # 2nd pass links each server to its outputs + starts boxes for any labels that don't appear on lhs
    {boxes, input_ref_counts} =
      input
      |> String.split("\n", trim: true)
      |> Enum.reduce(
        {%{"button" => {button, ["broadcaster"]}}, %{"broadcaster" => 1}},
        fn line, {boxes, ref_counts} ->
          [lhs, rhs] = String.split(line, " -> ")

          {behavior, label} =
            case lhs do
              "%" <> label -> {FlipFlop, label}
              "&" <> label -> {Conjunction, label}
              other -> {Broadcaster, other}
            end

          {:ok, box} = BoxAgent.start_link(behavior, counter, history, label)

          output_labels = String.split(rhs, ", ", trim: true)
          boxes = Map.put(boxes, label, {box, output_labels})

          new_ref_counts = Map.new(output_labels, &{&1, 1})
          ref_counts = Map.merge(ref_counts, new_ref_counts, fn _, n1, n2 -> n1 + n2 end)

          {boxes, ref_counts}
        end
      )

    boxes
    |> Stream.each(fn {box_label, {box, output_labels}} ->
      output_labels
      |> Enum.map(fn label ->
        Map.get_lazy(boxes, label, fn ->
          # This can be any type--it will have no outputs so it doesn't matter.
          {:ok, pid} = BoxAgent.start_link(Broadcaster, counter, history, label)
          {pid, []}
        end)
        |> elem(0)
      end)
      |> tap(fn output_pids ->
        BoxAgent.set_outputs(box, output_pids)
        BoxAgent.set_input_count(box, input_ref_counts[box_label])
      end)
    end)
    |> Stream.run()

    init_pulse = {false, nil, [button]}

    {init_pulse, counter, history, find_input_conjunctions(boxes)}
  end

  defp find_input_conjunctions(boxes) do
    rx_input =
      Enum.find_value(boxes, fn
        {label, {_, ["rx"]}} -> label
        _ -> false
      end)

    boxes
    |> Enum.filter(fn {_, {_, outputs}} -> rx_input in outputs end)
    |> Enum.map(fn {label, _} -> label end)
  end
end
