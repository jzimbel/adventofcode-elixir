defmodule AdventOfCode.Solution.Year2021.Day11 do
  alias AdventOfCode.CharGrid
  alias __MODULE__.FlashCounter
  alias __MODULE__.Octopus

  def part1(input) do
    octopuses = setup(input)

    result =
      octopuses
      |> Stream.unfold(&run_step/1)
      |> Enum.at(99)

    teardown(octopuses)

    result
  end

  def part2(input) do
    octopuses = setup(input)

    expected_flashes = length(octopuses)

    result =
      octopuses
      |> Stream.unfold(&run_step/1)
      |> Stream.chunk_every(2, 1)
      |> Stream.with_index(2)
      |> Enum.find_value(fn {[flash_count1, flash_count2], step} ->
        if flash_count2 - flash_count1 == expected_flashes, do: step
      end)

    teardown(octopuses)

    result
  end

  defp setup(input) do
    FlashCounter.start_link()

    grid = CharGrid.from_input(input)

    grid
    |> CharGrid.to_list()
    |> tap(fn cells ->
      Enum.each(cells, fn {coords, level_char} ->
        Octopus.start_link(coords, level_char - ?0, CharGrid.adjacent_coords(grid, coords))
      end)
    end)
    |> Enum.map(fn {coords, _} -> coords end)
  end

  defp teardown(octopuses) do
    FlashCounter.stop()
    Enum.each(octopuses, &Octopus.stop/1)
  end

  defp run_step(octopuses) do
    Enum.each(octopuses, &Octopus.increment/1)
    Enum.each(octopuses, &Octopus.maybe_flash/1)
    block_until_step_is_done(octopuses)
    {FlashCounter.value(), octopuses}
  end

  defp block_until_step_is_done(octopuses) do
    unless Enum.all?(octopuses, &Octopus.done?/1) do
      block_until_step_is_done(octopuses)
    end
  end
end

defmodule AdventOfCode.Solution.Year2021.Day11.FlashCounter do
  use Agent

  def start_link do
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  def stop do
    Agent.stop(__MODULE__)
  end

  def increment do
    Agent.cast(__MODULE__, &(&1 + 1))
  end

  def value do
    Agent.get(__MODULE__, &Function.identity/1)
  end
end

defmodule AdventOfCode.Solution.Year2021.Day11.Octopus do
  use Agent

  alias AdventOfCode.Solution.Year2021.Day11.FlashCounter

  defstruct level: 0,
            neighbors: []

  def start_link(coords, level, neighbors) do
    Agent.start_link(
      fn -> %__MODULE__{level: level, neighbors: neighbors} end,
      name: agent_name(coords)
    )
  end

  def stop(coords) do
    Agent.stop(agent_name(coords))
  end

  def increment(coords) do
    Agent.update(agent_name(coords), &do_increment/1)
  end

  def propagate_flash(coords) do
    Agent.cast(agent_name(coords), &do_propagate_flash/1)
  end

  def maybe_flash(coords) do
    Agent.cast(agent_name(coords), &do_maybe_flash/1)
  end

  def done?(coords) do
    Agent.get(agent_name(coords), &do_done?/1)
  end

  # A tick always increments
  defp do_increment(state), do: %{state | level: state.level + 1}

  # A neighbor's flash has no effect if this octopus has already flashed during this step
  defp do_propagate_flash(%{level: 0} = state), do: state

  # A neighbor's flash increments and may cause this octopus to flash
  defp do_propagate_flash(state) do
    do_maybe_flash(%{state | level: state.level + 1})
  end

  defp do_maybe_flash(%{level: level} = state) when level > 9 do
    flash(state.neighbors)
    %{state | level: 0}
  end

  defp do_maybe_flash(state), do: state

  defp flash(neighbors) do
    FlashCounter.increment()
    Enum.each(neighbors, &propagate_flash/1)
  end

  defp do_done?(_state) do
    match?({:messages, []}, Process.info(self(), :messages))
  end

  defp agent_name(coords), do: {:global, {__MODULE__, coords}}
end
