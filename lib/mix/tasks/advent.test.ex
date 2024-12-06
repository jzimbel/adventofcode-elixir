defmodule Mix.Tasks.Advent.Test do
  @moduledoc """
  Runs tests against solution modules.

  If you do not specify a day, all tests for a year will run.

  # USAGE
      mix advent.test [--year <year>] [--day <day>] [-- ...mix_test_opts]

  | Option | Info |
  | ------ | ---- |
  | `--day`, `-d` | Day number. If omitted, all tests in the year will run. |
  | `--year`, `-y` | Year. If omitted, defaults to current year (if it's December) or previous year (if it's another month) |
  | `--` | Everything after this separator is passed through to `mix test`. |

  If you want to run _all_ tests in the project, use `mix test`.
  """
  use Mix.Task
  @shortdoc "Runs Advent of Code solution tests"

  defmodule Args do
    @type t :: %__MODULE__{
            year: integer,
            day: 1..25 | :all,
            passthrough: [String.t()]
          }

    @enforce_keys [:year, :passthrough]
    defstruct @enforce_keys ++ [day: :all]

    @spec parse(list(String.t())) :: {:ok, t()} | :error
    def parse(raw_args) do
      {parsed, argv, invalid} = OptionParser.parse(raw_args, opts())
      # Opts used by advent.solve are allowed but ignored.
      parsed = parsed |> Map.new() |> Map.drop([:part, :bench])

      {argv, passthrough} =
        case Enum.find_index(argv, &(&1 == "--")) do
          nil -> {argv, []}
          0 -> {[], tl(argv)}
          i -> {Enum.slice(argv, 0..(i - 1)//1), Enum.slice(argv, (i + 1)..-1//1)}
        end

      parsed = Map.put(parsed, :passthrough, passthrough)

      cond do
        argv != [] ->
          task_name = Mix.Task.task_name(Mix.Tasks.Advent.Test)

          Mix.shell().error(
            "Unrecognized argument(s): #{inspect(argv)}. `#{task_name}` does not take any arguments; only options."
          )

          :error

        invalid != [] ->
          Mix.shell().error("Invalid option(s): #{inspect(invalid)}")

          :error

        Map.has_key?(parsed, :day) and parsed.day not in 1..25 ->
          Mix.shell().error(
            "Invalid --day option. If specified, --day must be an integer in 1..25."
          )

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
        strict: [year: :integer, day: :integer, part: :integer, bench: :boolean],
        return_separator: true
      ]
    end

    defp default_year do
      now_est = DateTime.now!("America/New_York")
      if now_est.month == 12, do: now_est.year, else: now_est.year - 1
    end
  end

  @impl Mix.Task
  def run(raw_args) do
    with {:ok, args} <- Args.parse(raw_args) do
      test_path = get_test_path(args)
      passthrough = Enum.join(args.passthrough, " ")
      cmd = Enum.join(["→ mix test", passthrough, test_path] |> Enum.reject(&(&1 == "")), " ")

      Mix.shell().info(IO.ANSI.format([:bright, cmd, "\n"]))

      Mix.Task.run("test", args.passthrough ++ [test_path])
    end

    Mix.Task.reenable(__MODULE__)
  end

  defp get_test_path(%{year: year, day: :all}) do
    Path.join(~w[test advent_of_code solution year_#{year}])
  end

  defp get_test_path(%{year: year, day: day}) do
    padded_day =
      day
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    %{year: year, day: :all}
    |> get_test_path()
    |> Path.join("day_#{padded_day}_test.exs")
  end
end
