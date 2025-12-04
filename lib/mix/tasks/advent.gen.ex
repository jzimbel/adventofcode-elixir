defmodule Mix.Tasks.Advent.Gen do
  @moduledoc """
  # USAGE
      mix advent.gen <--year <year>>

  # DESCRIPTION
  Generates source files for a new year of Advent of Code puzzles and populates them with boilerplate code.

  For years 2025 and later, the event was reduced from 25 to 12 days.
  As a result, fewer files will be generated for those years.

      /
      |- lib/
      | |- advent_of_code/
      | | |- solution/
      | | | |- year_${YEAR}/
      | | | | |- day_01.ex
      | | | | |- day_02.ex
      | | | | |- ...
      | | | | |- day_25.ex
      |- test/
      | |- advent_of_code/
      | | |- solution/
      | | | |- year_${YEAR}/
      | | | | |- day_01_test.ex
      | | | | |- day_02_test.ex
      | | | | |- ...
      | | | | |- day_25_test.ex
  """
  use Mix.Task
  @shortdoc "Generates source files for a new year of Advent of Code puzzles"

  require Mix.Generator

  @impl Mix.Task
  def run(args) do
    with {[year: year], _, []} when year >= 2015 <-
           OptionParser.parse(args, aliases: [y: :year], strict: [year: :integer]) do
      generate(year)
    else
      {[year: year], _, []} when year <= 2015 -> Mix.shell().error("Year must be 2015 or later.")
      _ -> Mix.shell().error("Invalid argument.")
    end
  end

  defp generate(year) do
    days = days_for_year(year)
    solution_dir = Path.join(lib_root_dir(), year_subdir(year))
    test_dir = Path.join(test_root_dir(), year_subdir(year))

    Mix.Generator.create_directory(solution_dir)
    Mix.Generator.create_directory(test_dir)

    for day <- days do
      filename = :io_lib.fwrite("day_~2..0B.ex", [day])

      Mix.Generator.create_file(
        Path.join(solution_dir, filename),
        solution_template(year: year, day: day)
      )
    end

    for day <- days do
      filename = :io_lib.format("day_~2..0B_test.exs", [day])

      Mix.Generator.create_file(
        Path.join(test_dir, filename),
        test_template(year: year, day: day)
      )
    end
  end

  defp days_for_year(year) when year in 2015..2024, do: 1..25
  defp days_for_year(year) when year >= 2025, do: 1..12

  defp lib_root_dir, do: Path.join(File.cwd!(), "lib")
  defp test_root_dir, do: Path.join(File.cwd!(), "test")

  defp year_subdir(year), do: Path.join(~w[advent_of_code solution year_#{year}])

  Mix.Generator.embed_template(:solution, """
  defmodule AdventOfCode.Solution.Year<%= @year %>.Day<%= :io_lib.format("~2..0B", [@day]) %> do
    def part1(_input) do
    end

    def part2(_input) do
    end
  end
  """)

  Mix.Generator.embed_template(:test, """
  defmodule AdventOfCode.Solution.Year<%= @year %>.Day<%= :io_lib.format("~2..0B", [@day]) %>Test do
    use ExUnit.Case, async: true

    import AdventOfCode.Solution.Year<%= @year %>.Day<%= :io_lib.format("~2..0B", [@day]) %>

    setup do
      [
        input: \"""
        \"""
      ]
    end

    @tag :skip
    test "part1", %{input: input} do
      result = part1(input)

      assert result
    end

    @tag :skip
    test "part2", %{input: input} do
      result = part2(input)

      assert result
    end
  end
  """)
end
