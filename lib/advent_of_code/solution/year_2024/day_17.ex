defmodule AdventOfCode.Solution.Year2024.Day17 do
  require Bitwise

  use AdventOfCode.Solution.SharedParse

  @enforce_keys [:a]
  defstruct [:a, b: 0, c: 0, ptr: 0]

  @impl true
  def parse(input) do
    [a, program] =
      ~r"Register A: (\d+).*Program: ([,\d]+)"s
      |> Regex.run(input, capture: :all_but_first)

    program =
      for {n, i} <- Enum.with_index(String.split(program, ",")), into: %{} do
        {i, String.to_integer(n)}
      end

    {%__MODULE__{a: String.to_integer(a)}, program}
  end

  def part1({init_state, program}), do: stream_output(init_state, program) |> Enum.join(",")
  def part2({_init_state, program}), do: gen_a(program) |> Enum.at(0)

  defp gen_a(program) do
    (map_size(program) - 1)..0//-1
    |> Enum.reduce([0], fn i, stream ->
      n = program[i]

      stream
      |> Stream.map(&Bitwise.bsl(&1, 3))
      |> Stream.flat_map(fn shifted_partial_a ->
        0..7
        |> Stream.flat_map(fn octet ->
          a = shifted_partial_a + octet
          if first_output(a, program) == n, do: [a], else: []
        end)
      end)
    end)
  end

  defp first_output(a, program) do
    Enum.at(stream_output(%__MODULE__{a: a}, program), 0)
  end

  defp stream_output(init_state, program) do
    Stream.resource(fn -> init_state end, &next(&1, program), fn _final_state -> nil end)
  end

  defp next(state, program) when is_map_key(program, state.ptr) do
    opcode = Map.fetch!(program, state.ptr)
    arg = program |> Map.fetch!(state.ptr + 1) |> resolve_arg(opcode, state)
    op(opcode, arg, state)
  end

  defp next(state, _program), do: {:halt, state}

  defp op(opcode, n, state) do
    case opcode do
      0 -> {[], inc_ptr(put_in(state.a, div(state.a, 2 ** n)))}
      1 -> {[], inc_ptr(put_in(state.b, Bitwise.bxor(state.b, n)))}
      2 -> {[], inc_ptr(put_in(state.b, rem(n, 8)))}
      3 -> {[], if(state.a != 0, do: put_in(state.ptr, n), else: inc_ptr(state))}
      4 -> {[], inc_ptr(put_in(state.b, Bitwise.bxor(state.b, state.c)))}
      5 -> {[rem(n, 8)], inc_ptr(state)}
      6 -> {[], inc_ptr(put_in(state.b, div(state.a, 2 ** n)))}
      7 -> {[], inc_ptr(put_in(state.c, div(state.a, 2 ** n)))}
    end
  end

  defp resolve_arg(arg, opcode, _state)
       when opcode in [1, 3, 4]
       when arg not in 4..7,
       do: arg

  defp resolve_arg(arg, _combo_opcode, state) do
    case arg do
      4 -> state.a
      5 -> state.b
      6 -> state.c
      7 -> raise "combo arg 7 not implemented"
    end
  end

  defp inc_ptr(state), do: put_in(state.ptr, state.ptr + 2)
end
