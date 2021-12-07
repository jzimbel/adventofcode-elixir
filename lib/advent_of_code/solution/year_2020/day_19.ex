defmodule AdventOfCode.Solution.Year2020.Day19 do
  @literal_pattern ~r/"(\w)"/

  def part1(args) do
    {rules_pattern, messages} = parse_input(args)

    Enum.count(messages, &Regex.match?(rules_pattern, &1))
  end

  def part2(_args) do
    nil
  end

  defp parse_input(input) do
    [rules, messages] =
      input
      |> String.trim()
      |> String.split("\n\n", trim: true)

    {parse_rules_pattern(rules), String.split(messages)}
  end

  defp parse_rules_pattern(rules) do
    rules
    |> String.split("\n")
    |> Enum.into(%{}, &parse_rule/1)
    |> rules_to_regex_source()
    |> whole_line()
    |> IO.iodata_to_binary()
    |> Regex.compile!()
  end

  defp parse_rule(rule_line) do
    [index, rule] = String.split(rule_line, ": ")

    tag =
      cond do
        String.contains?(rule, "|") -> :disjunction
        Regex.match?(@literal_pattern, rule) -> :literal
        true -> :references
      end

    vals = String.split(rule)

    parsed_rule =
      case tag do
        :disjunction ->
          Enum.map(vals, fn
            "|" -> "|"
            n -> String.to_integer(n)
          end)

        :references ->
          Enum.map(vals, &String.to_integer/1)

        :literal ->
          @literal_pattern
          |> Regex.run(hd(vals), capture: :all_but_first)
          |> hd()
      end

    {String.to_integer(index), {tag, parsed_rule}}
  end

  defp rules_to_regex_source(rules, i \\ 0) do
    case rules[i] do
      {:disjunction, indexes} ->
        indexes
        |> Enum.map(fn
          "|" -> "|"
          index -> rules_to_regex_source(rules, index)
        end)
        |> non_capture_group()

      {:references, indexes} ->
        Enum.map(indexes, &rules_to_regex_source(rules, &1))

      {:literal, char} ->
        char
    end
  end

  defp whole_line(pattern_source) do
    [?^, pattern_source, ?$]
  end

  defp non_capture_group(pattern_source) do
    ['(?:', pattern_source, ?)]
  end
end
