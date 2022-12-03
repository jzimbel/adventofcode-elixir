defmodule Mix.Tasks.Advent.Solve do
  use Mix.Task

  @task_name :"advent.solve"

  @shortdoc "Runs an Advent of Code puzzle solution"

  @moduledoc """
  # USAGE
  ```
  mix #{@task_name} [--year <year>] <--day <day>> <--part <part>> [--bench]
  ```

  ## Required
  - `--day`, `-d`    Day number. (1..25 inclusive)
  - `--part`, `-p`   Part number. (either 1 or 2)

  ## Optional
  - `--year`, `-y`   Year. If not passed, defaults to current year (if it's December) or previous year (if it's another month)

  - `--bench`, `-b`  Run benchmarks.
  """

  @opts [
    aliases: [y: :year, d: :day, p: :part, b: :bench],
    strict: [year: :integer, day: :integer, part: :integer, bench: :boolean]
  ]

  @impl Mix.Task
  def run(raw_args) do
    with {:ok, args} <- parse_args(raw_args),
         {:ok, solution_fn} <- fetch_solution_function(args) do
      input = AdventOfCode.Input.get!(args.day, args.year)

      if args.bench do
        Benchee.run(%{result: fn -> solution_fn.(input) end})
      else
        input
        |> solution_fn.()
        |> then(&print_solution(Mix.shell(), &1, label: "Part #{args.part} Results"))
      end
    else
      :error -> nil
    end

    Mix.Task.reenable(@task_name)
  end

  defp parse_args(raw_args) do
    {parsed, _, invalid} = OptionParser.parse(raw_args, @opts)
    parsed = Map.new(parsed)

    with {:check_invalid, []} <- {:check_invalid, invalid},
         {:check_parsed, %{day: day, part: part}} when day in 1..25 and part in 1..2 <-
           {:check_parsed, parsed} do
      parsed
      |> Map.put_new_lazy(:year, &default_year/0)
      |> Map.put_new(:bench, false)
      |> then(&{:ok, &1})
    else
      {:check_invalid, _} ->
        Mix.shell()
        |> print_error("Invalid argument.")

        :error

      {:check_parsed, _} ->
        Mix.shell()
        |> print_error("Missing one or more argument, or an argument is invalid.")

        :error
    end
  end

  defp fetch_solution_function(%{year: year, day: day, part: part}) do
    day_alias =
      "Day~2..0B"
      |> :io_lib.format([day])
      |> to_string()

    module = Module.concat([AdventOfCode, Solution, "Year#{year}", day_alias])
    function = String.to_atom("part#{part}")

    with {:module, _} <- Code.ensure_loaded(module),
         true <- function_exported?(module, function, 1) do
      {:ok, Function.capture(module, function, 1)}
    else
      {:error, _} ->
        Mix.shell()
        |> print_error("Module `#{inspect(module)}` is not defined.")

        :error

      false ->
        Mix.shell()
        |> print_error("Function `#{inspect(module)}.#{function}/1` is not defined.")

        :error
    end
  end

  defp default_year do
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
