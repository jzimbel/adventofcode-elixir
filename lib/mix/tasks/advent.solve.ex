defmodule Mix.Tasks.Advent.Solve do
  use Mix.Task

  @task_name :"advent.solve"

  @shortdoc "Runs an Advent of Code puzzle solution"

  @moduledoc """
  # USAGE
  ```
  mix #{@task_name} [--year <year>] <--day <day>> [--part <part>] [--bench]
  ```

  ## Required
  - `--day`, `-d`    Day number. (1..25 inclusive)

  ## Optional
  - `--year`, `-y`   Year. If omitted, defaults to current year (if it's December) or previous year (if it's another month)
  - `--part`, `-p`   Part number. Either 1 or 2. If omitted, both parts for that day will run.
  - `--bench`, `-b`  Run benchmarks.
  """

  @opts [
    aliases: [y: :year, d: :day, p: :part, b: :bench],
    strict: [year: :integer, day: :integer, part: :integer, bench: :boolean]
  ]

  @type t :: %__MODULE__{
          year: integer,
          day: 1..25,
          part: 1 | 2 | :both,
          bench: boolean
        }

  @enforce_keys [:year, :day]
  defstruct @enforce_keys ++ [part: :both, bench: false]

  @impl Mix.Task
  def run(raw_args) do
    with {:ok, args} <- parse_args(raw_args),
         {:ok, module} <- fetch_solution_module(args) do
      is_shared_parse = shared_parse?(module)
      input = AdventOfCode.Input.get!(args.day, args.year)
      do_run(args, module, input, is_shared_parse)
    end

    Mix.Task.reenable(@task_name)
  end

  defp do_run(%{part: :both, bench: false}, module, input, false) do
    run_and_print_result(module, 1, input)
    run_and_print_result(module, 2, input)
  end

  defp do_run(%{part: :both, bench: false}, module, input, true) do
    parsed = module.parse(input)
    run_and_print_result(module, 1, parsed)
    run_and_print_result(module, 2, parsed)
  end

  defp do_run(%{part: :both, bench: true}, module, input, false) do
    Benchee.run(
      %{
        part1: fn -> module.part1(input) end,
        part2: fn -> module.part2(input) end
      },
      print: [configuration: false]
    )
  end

  defp do_run(%{part: :both, bench: true}, module, input, true) do
    parsed = module.parse(input)

    Benchee.run(
      %{
        parse: fn -> module.parse(input) end,
        part1: fn -> module.part1(parsed) end,
        part2: fn -> module.part2(parsed) end
      },
      print: [configuration: false]
    )
  end

  defp do_run(%{part: n, bench: false}, module, input, false) do
    run_and_print_result(module, n, input)
  end

  defp do_run(%{part: n, bench: false}, module, input, true) do
    parsed = module.parse(input)
    run_and_print_result(module, n, parsed)
  end

  defp do_run(%{part: n, bench: true}, module, input, false) do
    Benchee.run(%{"part#{n}": fn -> apply(module, :"part#{n}", [input]) end},
      print: [configuration: false]
    )
  end

  defp do_run(%{part: n, bench: true}, module, input, true) do
    parsed = module.parse(input)

    Benchee.run(
      %{
        parse: fn -> module.parse(input) end,
        "part#{n}": fn -> apply(module, :"part#{n}", [parsed]) end
      },
      print: [configuration: false]
    )
  end

  defp run_and_print_result(module, part, input) do
    result = apply(module, :"part#{part}", [input])
    print_solution(Mix.shell(), result, label: "Part #{part} Results")
  end

  @spec parse_args(list) :: {:ok, t()} | :error
  defp parse_args(raw_args) do
    {parsed, argv, invalid} = OptionParser.parse(raw_args, @opts)
    parsed = Map.new(parsed)

    cond do
      argv != [] ->
        Mix.shell()
        |> print_error(
          "Unrecognized argument(s): #{inspect(argv)}. `#{@task_name}` does not take any arguments; only options."
        )

        :error

      invalid != [] ->
        Mix.shell()
        |> print_error("Invalid option(s): #{inspect(invalid)}")

        :error

      not Map.has_key?(parsed, :day) or parsed.day not in 1..25 ->
        Mix.shell()
        |> print_error(
          "Missing or invalid --day option. --day must be specified, and must be an integer in 1..25."
        )

        :error

      Map.has_key?(parsed, :part) and parsed.part not in 1..2 ->
        Mix.shell()
        |> print_error("Invalid --part option. If specified, --part must be either 1 or 2.")

        :error

      true ->
        parsed
        |> Map.put_new_lazy(:year, &default_year/0)
        |> then(&struct!(__MODULE__, &1))
        |> then(&{:ok, &1})
    end
  end

  defp fetch_solution_module(%{year: year, day: day}) do
    day_alias =
      "Day~2..0B"
      |> :io_lib.format([day])
      |> to_string()

    module = Module.concat([AdventOfCode, Solution, "Year#{year}", day_alias])

    cond do
      not match?({:module, _}, Code.ensure_loaded(module)) ->
        print_error(Mix.shell(), "Module `#{inspect(module)}` is not defined.")

      not function_exported?(module, :part1, 1) ->
        print_error(Mix.shell(), "Function `#{inspect(module)}.part1/1` is not defined.")

      not function_exported?(module, :part2, 1) ->
        print_error(Mix.shell(), "Function `#{inspect(module)}.part2/1` is not defined.")

      true ->
        {:ok, module}
    end
  end

  defp shared_parse?(module) do
    case Keyword.fetch(module.__info__(:attributes), :__shared_parse__) do
      {:ok, [true]} -> true
      :error -> false
    end
  end

  defp default_year do
    # Bit of corner-cutting since AOC puzzles release at midnight in my time zone.
    # A more correct approach would require a TZ database library.
    case :calendar.local_time() do
      {{y, 12, _}, _} -> y
      {{y, _, _}, _} -> y - 1
    end
  end

  defp print_error(shell, message) do
    tap(shell, & &1.error(message))
  end

  defp print_solution(shell, solution, opts) do
    tap(shell, fn s ->
      solution
      |> format()
      |> highlight()
      |> label(opts[:label])
      |> s.info()
    end)
  end

  defp format(solution) when is_binary(solution) do
    if String.contains?(solution, "\n"), do: [?\n, solution], else: solution
  end

  defp format(solution), do: inspect(solution)

  defp highlight(message) do
    [IO.ANSI.bright(), IO.ANSI.green(), message, IO.ANSI.reset()]
  end

  defp label(message, nil), do: message

  defp label(message, label), do: [label, ': ', message]
end
