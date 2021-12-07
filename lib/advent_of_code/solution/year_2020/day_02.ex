defmodule AdventOfCode.Solution.Year2020.Day02 do
  defmodule Password do
    @enforce_keys ~w[char n1 n2 password]a
    defstruct @enforce_keys

    def parse(line) do
      fields =
        ~r|^(?<n1>\d+)-(?<n2>\d+) (?<char>\w): (?<password>\w+)$|
        |> Regex.named_captures(line)
        |> Enum.map(fn {k, _v} = entry ->
          {String.to_existing_atom(k), parse_value(entry)}
        end)

      struct(__MODULE__, fields)
    end

    defp parse_value({"n1", n1}), do: String.to_integer(n1)
    defp parse_value({"n2", n2}), do: String.to_integer(n2)
    defp parse_value({"char", char}), do: hd(String.to_charlist(char))
    defp parse_value({"password", password}), do: password

    def valid_p1?(%__MODULE__{char: char, n1: n1, n2: n2, password: password}) do
      char_count =
        password
        |> String.to_charlist()
        |> Enum.count(&(&1 == char))

      Enum.member?(n1..n2, char_count)
    end

    def valid_p2?(%__MODULE__{char: char, n1: n1, n2: n2, password: password}) do
      chars = String.to_charlist(password)

      case {Enum.at(chars, n1 - 1), Enum.at(chars, n2 - 1)} do
        {^char, ^char} -> false
        {^char, _} -> true
        {_, ^char} -> true
        _ -> false
      end
    end
  end

  def part1(args) do
    args
    |> parse_input()
    |> Enum.count(&Password.valid_p1?/1)
  end

  def part2(args) do
    args
    |> parse_input()
    |> Enum.count(&Password.valid_p2?/1)
  end

  defp parse_input(args) do
    args
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&Password.parse/1)
  end
end
