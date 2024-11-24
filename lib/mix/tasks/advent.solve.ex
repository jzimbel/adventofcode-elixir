defmodule Mix.Tasks.Advent.Solve do
  @moduledoc """
  # USAGE
  ```
  mix #{Mix.Task.task_name(__MODULE__)} [--year <year>] <--day <day>> [--part <part>] [--bench]
  ```

  ## Required
  - `--day`, `-d`    Day number. (1..25 inclusive)

  ## Optional
  - `--year`, `-y`   Year. If omitted, defaults to current year (if it's December) or previous year (if it's another month)
  - `--part`, `-p`   Part number. Either 1 or 2. If omitted, both parts for that day will run.
  - `--bench`, `-b`  Run benchmarks.
  """

  @shortdoc "Runs an Advent of Code puzzle solution"

  use Mix.Task

  defmodule Args do
    @type t :: %__MODULE__{
            year: integer,
            day: 1..25,
            part: 1 | 2 | :both,
            bench: boolean
          }

    @enforce_keys [:year, :day]
    defstruct @enforce_keys ++ [part: :both, bench: false]

    @spec parse(list(String.t())) :: {:ok, t()} | :error
    def parse(raw_args) do
      {parsed, argv, invalid} = OptionParser.parse(raw_args, opts())
      parsed = Map.new(parsed)

      cond do
        argv != [] ->
          task_name = Mix.Task.task_name(Mix.Tasks.Advent.Solve)

          Mix.shell().error(
            "Unrecognized argument(s): #{inspect(argv)}. `#{task_name}` does not take any arguments; only options."
          )

          :error

        invalid != [] ->
          Mix.shell().error("Invalid option(s): #{inspect(invalid)}")

          :error

        not Map.has_key?(parsed, :day) or parsed.day not in 1..25 ->
          Mix.shell().error(
            "Missing or invalid --day option. --day must be specified, and must be an integer in 1..25."
          )

          :error

        Map.has_key?(parsed, :part) and parsed.part not in 1..2 ->
          Mix.shell().error("Invalid --part option. If specified, --part must be either 1 or 2.")

          :error

        true ->
          parsed
          |> Map.put_new_lazy(:year, &default_year/0)
          |> then(&struct!(__MODULE__, &1))
          |> then(&{:ok, &1})
      end
    end

    defp opts do
      [
        aliases: [y: :year, d: :day, p: :part, b: :bench],
        strict: [year: :integer, day: :integer, part: :integer, bench: :boolean]
      ]
    end

    defp default_year do
      now_est = DateTime.now!("America/New_York")
      if now_est.month == 12, do: now_est.year, else: now_est.year - 1
    end
  end

  @impl Mix.Task
  def run(raw_args) do
    with {:ok, args} <- Args.parse(raw_args),
         {:ok, module} <- fetch_solution_module(args) do
      input = AdventOfCode.Input.get!(args.day, args.year)

      setting_combo_id = get_setting_combo_id(args, shared_parse?(module))

      "Advent of Code #{args.year} - day #{args.day}\n"
      |> ansi_heading()
      |> Mix.shell().info()

      do_run(setting_combo_id, module, args.part, input)

      Mix.shell().info("")
    end

    Mix.Task.reenable(__MODULE__)
  end

  # Setting combo: a shorthand for 3 boolean flags.
  # "mbs" - multipart (run both part 1 and part 2) | benchmarking | shared parse
  # A "." means the flag is disabled.
  #
  # Example:
  # "m.s" -> multipart ENABLED | benchmarking DISABLED | shared parse ENABLED
  defp get_setting_combo_id(%Args{part: part, bench: bench}, shared_parse) do
    multipart = part == :both
    Enum.map_join([multipart and "m", bench and "b", shared_parse and "s"], &(&1 || "."))
  end

  defp do_run(setting_combo_id, module, part, input)

  defp do_run("...", module, part, input) do
    run_and_print_result(module, part, input)
  end

  defp do_run("..s", module, part, input) do
    parsed = module.parse(input)
    run_and_print_result(module, part, parsed)
  end

  defp do_run(".b.", module, part, input) do
    run_benchmarks(%{"Part #{part}": fn -> apply(module, :"part#{part}", [input]) end})
  end

  defp do_run(".bs", module, part, input) do
    parsed = module.parse(input)

    run_benchmarks(%{
      Parse: fn -> module.parse(input) end,
      "Part #{part}": fn -> apply(module, :"part#{part}", [parsed]) end
    })
  end

  defp do_run("m..", module, _part, input) do
    run_and_print_result(module, 1, input)
    run_and_print_result(module, 2, input)
  end

  defp do_run("m.s", module, _part, input) do
    parsed = module.parse(input)
    run_and_print_result(module, 1, parsed)
    run_and_print_result(module, 2, parsed)
  end

  defp do_run("mb.", module, _part, input) do
    run_benchmarks(%{
      "Part 1": fn -> module.part1(input) end,
      "Part 2": fn -> module.part2(input) end
    })
  end

  defp do_run("mbs", module, _part, input) do
    parsed = module.parse(input)

    run_benchmarks(%{
      Parse: fn -> module.parse(input) end,
      "Part 1": fn -> module.part1(parsed) end,
      "Part 2": fn -> module.part2(parsed) end
    })
  end

  defp run_benchmarks(benchmarks) do
    Benchee.run(benchmarks, print: [configuration: false])
  end

  defp run_and_print_result(module, part, input) do
    result = apply(module, :"part#{part}", [input])
    print_solution(result, "Part #{part} Result")
  end

  defp fetch_solution_module(%{year: year, day: day}) do
    day_alias =
      day
      |> Integer.to_string()
      |> String.pad_leading(2, "0")
      |> then(&"Day#{&1}")

    module = Module.concat([AdventOfCode, Solution, "Year#{year}", day_alias])

    cond do
      not match?({:module, _}, Code.ensure_loaded(module)) ->
        Mix.shell().error("Module `#{inspect(module)}` is not defined.")

      not function_exported?(module, :part1, 1) ->
        Mix.shell().error("Function `#{inspect(module)}.part1/1` is not defined.")

      not function_exported?(module, :part2, 1) ->
        Mix.shell().error("Function `#{inspect(module)}.part2/1` is not defined.")

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

  defp print_solution(solution, label) do
    solution
    |> format()
    |> ansi_solution()
    |> label(label)
    |> Mix.shell().info()
  end

  defp format(solution) when is_binary(solution) do
    if String.contains?(solution, "\n"), do: [?\n, solution], else: solution
  end

  defp format(solution), do: inspect(solution)

  defp ansi_heading(message) do
    IO.ANSI.format([:bright, :underline, message])
  end

  defp ansi_solution(message) do
    IO.ANSI.format([:bright, :green, message])
  end

  defp label(message, label), do: [label, ": ", message]
end
