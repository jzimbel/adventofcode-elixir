defmodule AdventOfCode.Day04 do
  @required_fields MapSet.new(~w[byr iyr eyr hgt hcl ecl pid])

  def part1(args) do
    args
    |> parse_pass_data()
    |> Enum.map(&parse_pass_fields/1)
    |> Enum.count(&pass_valid_p1?/1)
  end

  def part2(args) do
    args
    |> parse_pass_data()
    |> Enum.map(&parse_pass_values/1)
    |> Enum.count(&pass_valid_p2?/1)
  end

  defp parse_pass_data(input) do
    input
    |> String.trim()
    |> String.split("\n\n")
  end

  defp parse_pass_fields(pass_data) do
    ~r|(\w+):|
    |> Regex.scan(pass_data, capture: :all_but_first)
    |> Enum.flat_map(&Function.identity/1)
    |> Enum.into(MapSet.new())
  end

  defp pass_valid_p1?(pass_fields) do
    MapSet.subset?(@required_fields, pass_fields)
  end

  defp parse_pass_values(pass_data) do
    ~r|(\w+):([^\s]+)|
    |> Regex.scan(pass_data, capture: :all_but_first)
    |> Enum.into(%{}, fn [k, v] -> {k, v} end)
  end

  defp pass_valid_p2?(pass_values) do
    valid_p1? =
      pass_values
      |> Map.keys()
      |> MapSet.new()
      |> pass_valid_p1?()

    valid_p1? and Enum.all?(pass_values, &valid_value?/1)
  end

  @byr_range 1920..2002
  @iyr_range 2010..2020
  @eyr_range 2020..2030
  @hgt_cm_range 150..193
  @hgt_in_range 59..76
  @ecl_options MapSet.new(~w[amb blu brn gry grn hzl oth])

  defp valid_value?({"byr", val}) do
    String.to_integer(val) in @byr_range
  end

  defp valid_value?({"iyr", val}) do
    String.to_integer(val) in @iyr_range
  end

  defp valid_value?({"eyr", val}) do
    String.to_integer(val) in @eyr_range
  end

  defp valid_value?({"hgt", val}) do
    with {:cm, nil} <- {:cm, Regex.run(~r|^(\d+)cm$|, val, capture: :all_but_first)},
         {:in, nil} <- {:in, Regex.run(~r|^(\d+)in$|, val, capture: :all_but_first)} do
      false
    else
      {:cm, [height]} ->
        String.to_integer(height) in @hgt_cm_range

      {:in, [height]} ->
        String.to_integer(height) in @hgt_in_range
    end
  end

  defp valid_value?({"hcl", val}) do
    Regex.match?(~r|^#[0-9a-f]{6}$|, val)
  end

  defp valid_value?({"ecl", val}) do
    val in @ecl_options
  end

  defp valid_value?({"pid", val}) do
    Regex.match?(~r|^\d{9}$|, val)
  end

  defp valid_value?({"cid", _val}) do
    true
  end
end
