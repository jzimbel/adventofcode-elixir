defmodule AdventOfCode.Solution.Year2023.Day19 do
  @type workflow :: list(expr)
  @type expr :: {test, action}
  @type test :: {:> | :<, prop, integer}
  @type action :: :accept | :reject | {:jump, label}

  @type part :: %{prop => integer}
  @type part_range :: %{prop => Range.t()}

  @type label :: String.t()
  @type prop :: :x | :m | :a | :s

  use AdventOfCode.Solution.SharedParse

  @spec parse(String.t()) :: {%{label => workflow}, list(part)}
  def parse(input) do
    [workflows, parts] = String.split(input, "\n\n")
    {parse_workflows(workflows), parse_parts(parts)}
  end

  def part1({workflows, parts}) do
    ranges = passing_part_ranges(workflows)

    for part <- parts, Enum.any?(ranges, &part_in_range?(part, &1)), reduce: 0 do
      sum -> sum + Enum.sum(Map.values(part))
    end
  end

  def part2({workflows, _parts}) do
    for part_range <- passing_part_ranges(workflows), reduce: 0 do
      sum -> sum + part_range_size(part_range)
    end
  end

  @init_part_range Map.new([:x, :m, :a, :s], &{&1, 1..4000//1})

  @spec passing_part_ranges(%{label => workflow}) :: list(part_range)
  @spec passing_part_ranges(part_range, %{label => workflow}, label) :: list(part_range)
  defp passing_part_ranges(part_range \\ @init_part_range, workflows, cur \\ "in") do
    workflows[cur]
    |> Enum.flat_map_reduce(part_range, fn {{cmp, prop, n}, action}, cur_range ->
      if part_range_size(cur_range) > 0 do
        {pass, fail} = pass_fail(cmp, cur_range, prop, n)

        case {part_range_size(pass), action} do
          {0, _} -> {[], fail}
          {_, {:jump, label}} -> {passing_part_ranges(pass, workflows, label), fail}
          {_, :accept} -> {[pass], fail}
          {_, :reject} -> {[], fail}
        end
      else
        {:halt, cur_range}
      end
    end)
    |> then(fn {part_ranges, _empty_final_failing_part_range} -> part_ranges end)
  end

  @spec pass_fail(:> | :<, part_range, prop, integer) :: {pass :: part_range, fail :: part_range}
  defp pass_fail(:>, cur_range, prop, n) do
    l..r//1 = cur_range[prop]
    {Map.put(cur_range, prop, max(n + 1, l)..r//1), Map.put(cur_range, prop, l..min(n, r)//1)}
  end

  defp pass_fail(:<, cur_range, prop, n) do
    l..r//1 = cur_range[prop]
    {Map.put(cur_range, prop, l..min(n - 1, r)//1), Map.put(cur_range, prop, max(n, l)..r//1)}
  end

  defp part_range_size(part_range) do
    part_range
    |> Map.values()
    |> Enum.map(&Range.size/1)
    |> Enum.product()
  end

  defp part_in_range?(p, pr), do: Enum.all?(p, fn {k, v} -> v in pr[k] end)

  defp parse_workflows(workflows) do
    for workflow <- String.split(workflows, "\n", trim: true), into: %{} do
      [label, exprs] = Regex.run(~r"(\w+)\{(.+)\}", workflow, capture: :all_but_first)
      exprs = String.split(exprs, ",")

      {label, Enum.map(exprs, &parse_expr/1)}
    end
  end

  defp parse_expr(expr) do
    case String.split(expr, ":") do
      [condition, action] -> {parse_condition(condition), parse_action(action)}
      [action] -> {{:>, :x, 0}, parse_action(action)}
    end
  end

  defp parse_condition(condition) do
    [prop, cmp, n] = Regex.run(~r"([xmas])([><])(\d+)", condition, capture: :all_but_first)
    {String.to_existing_atom(cmp), String.to_existing_atom(prop), String.to_integer(n)}
  end

  defp parse_parts(parts) do
    for part <- String.split(parts, "\n", trim: true) do
      ~r"\d+"
      |> Regex.scan(part)
      |> Enum.map(fn [value] -> String.to_integer(value) end)
      |> Enum.zip_with([:x, :m, :a, :s], fn value, label -> {label, value} end)
      |> Map.new()
    end
  end

  defp parse_action("A"), do: :accept
  defp parse_action("R"), do: :reject
  defp parse_action(label), do: {:jump, label}
end
