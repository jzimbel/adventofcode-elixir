defmodule Mix.Tasks.Advent.Gen do
  use Mix.Task
  require Mix.Generator

  @shortdoc "Generates source files for a new year of Advent of Code puzzles"

  @moduledoc """
  # USAGE
  ```
  mix advent.gen <--year <year>>
  ```

  # DESCRIPTION
  Generates source files for a new year of Advent of Code puzzles and populates them with boilerplate code.

  ```
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
  ```
  """

  @days 1..25

  @impl Mix.Task
  def run(args) do
    with {[year: year], _, []} when year >= 2015 <-
           OptionParser.parse(args, aliases: [y: :year], strict: [year: :integer]) do
      generate(year)
    else
      _ -> Mix.shell().error("Invalid argument.")
    end
  end

  defp generate(year) do
    solution_dir = Path.join(lib_root_dir(), year_subdir(year))
    test_dir = Path.join(test_root_dir(), year_subdir(year))

    Enum.each([solution_dir, test_dir], &Mix.Generator.create_directory/1)

    Enum.each(
      @days,
      &Mix.Generator.create_file(
        Path.join(
          solution_dir,
          :io_lib.format("day_~2..0B.ex", [&1])
        ),
        solution_template(year: year, day: &1)
      )
    )

    Enum.each(
      @days,
      &Mix.Generator.create_file(
        Path.join(
          test_dir,
          :io_lib.format("day_~2..0B_test.exs", [&1])
        ),
        test_template(year: year, day: &1)
      )
    )
  end

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
