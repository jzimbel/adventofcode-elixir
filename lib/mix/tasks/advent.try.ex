defmodule Mix.Tasks.Advent.Try do
  @moduledoc """
  Runs tests for the given day, then runs the solution if no tests fail.

  Command options are the same as those for `advent.solve`.

  # USAGE
      mix advent.try [--year <year>] <--day <day>> [--part <part>] [--bench]

  ## Required
  | Option | Info |
  | ------ | ---- |
  | `--day`, `-d` | Day number. (1..25 inclusive) |

  ## Optional
  | Option | Info |
  | ------ | ---- |
  | `--year`, `-y` | Year. If omitted, defaults to current year (if it's December) or previous year (if it's another month) |
  | `--part`, `-p` | Part number. Either 1 or 2. If omitted, both parts for that day will run. |
  | `--bench`, `-b` | Run benchmarks if tests pass. |
  """
  use Mix.Task
  @shortdoc "Runs tests followed by solution for an Advent of Code puzzle"

  def run(args) do
    Mix.env(:test)
    Mix.Task.run("advent.test", args ++ ["--", "--raise"])

    Mix.shell().info(IO.ANSI.format([:bright, :yellow, "\nTests passed 😎\n"]))

    Mix.env(:dev)
    Mix.Task.run("advent.solve", args)
  end
end
