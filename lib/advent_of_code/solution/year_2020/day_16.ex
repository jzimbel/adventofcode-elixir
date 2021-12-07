defmodule AdventOfCode.Solution.Year2020.Day16 do
  def part1(args) do
    {rules, _, nearby_tickets} = parse_input(args)

    nearby_tickets
    |> Enum.flat_map(&invalid_values(&1, rules))
    |> Enum.sum()
  end

  def part2(args) do
    {rules, my_ticket, nearby_tickets} = parse_input(args)

    nearby_tickets
    |> Enum.reject(&invalid_ticket?(&1, rules))
    |> assign_fields(rules)
    |> Enum.zip(my_ticket)
    |> Enum.filter(fn {field, _} -> String.starts_with?(field, "departure") end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.reduce(1, &Kernel.*/2)
  end

  defp parse_input(input) do
    [rules, my_ticket, nearby_tickets] =
      input
      |> String.trim()
      |> String.split("\n\n", trim: true)

    {parse_rules(rules), parse_my_ticket(my_ticket), parse_nearby_tickets(nearby_tickets)}
  end

  defp parse_rules(rules) do
    rules
    |> String.split("\n")
    |> Enum.map(&parse_rule/1)
  end

  defp parse_rule(rule) do
    [field | bounds] =
      Regex.run(~r|([^:]+): (\d+)-(\d+) or (\d+)-(\d+)|, rule, capture: :all_but_first)

    [l1, r1, l2, r2] = Enum.map(bounds, &String.to_integer/1)

    validator = fn n -> n in l1..r1 or n in l2..r2 end

    {field, validator}
  end

  defp parse_my_ticket(my_ticket) do
    my_ticket
    |> String.split("\n")
    |> Enum.at(1)
    |> parse_ticket()
  end

  defp parse_nearby_tickets(nearby_tickets) do
    nearby_tickets
    |> String.split("\n")
    |> Enum.drop(1)
    |> Enum.map(&parse_ticket/1)
  end

  defp parse_ticket(ticket) do
    ticket
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp invalid_values(ticket, rules) do
    Enum.filter(ticket, &invalid_value?(&1, rules))
  end

  defp invalid_ticket?(ticket, rules) do
    Enum.any?(ticket, &invalid_value?(&1, rules))
  end

  defp invalid_value?(value, rules) do
    Enum.all?(rules, fn {_, validator} -> not validator.(value) end)
  end

  defp assign_fields(tickets, rules) do
    tickets
    |> columnize()
    |> list_valid_fields(rules)
    |> deduce()
  end

  defp columnize([ticket | tickets]) do
    acc = Enum.map(ticket, &[&1])

    Enum.reduce(tickets, acc, fn ticket, acc ->
      acc
      |> Enum.zip(ticket)
      |> Enum.map(fn {values, value} -> [value | values] end)
    end)
  end

  defp list_valid_fields(field_values, rules) do
    field_values
    |> Enum.map(fn values ->
      rules
      |> Enum.filter(fn {_, validator} -> Enum.all?(values, &validator.(&1)) end)
      |> Enum.map(&elem(&1, 0))
    end)
  end

  defp deduce(valid_fields) do
    case Enum.find(valid_fields, &match?([_], &1)) do
      nil ->
        valid_fields

      [resolved] ->
        valid_fields
        |> Enum.map(fn
          [^resolved] -> resolved
          fields when is_list(fields) -> fields -- [resolved]
          field -> field
        end)
        |> deduce()
    end
  end
end
