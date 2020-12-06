defmodule AdventOfCode.Day04 do
  @required_keys MapSet.new(~w[byr iyr eyr hgt hcl ecl pid])

  def part1(args) do
    args
    |> parse_pass_data()
    |> Enum.map(&parse_pass_keys/1)
    |> Enum.count(&pass_valid_p1?/1)
  end

  def part2(args) do
    args
    |> parse_pass_data()
    |> Enum.map(&parse_pass_entries/1)
    |> Enum.count(&pass_valid_p2?/1)
  end

  defp parse_pass_data(input) do
    input
    |> String.trim()
    |> String.split("\n\n")
  end

  ### Part 1 functions

  defp parse_pass_keys(pass_data) do
    ~r|(\w+):|
    |> Regex.scan(pass_data, capture: :all_but_first)
    |> Enum.flat_map(&Function.identity/1)
    |> Enum.into(MapSet.new())
  end

  defp pass_valid_p1?(pass_keys) do
    MapSet.subset?(@required_keys, pass_keys)
  end

  ### Part 2 functions

  defp parse_pass_entries(pass_data) do
    Regex.scan(~r|(\w+):([^\s]+)|, pass_data, capture: :all_but_first)
  end

  defp pass_valid_p2?(pass_entries) do
    valid_p1? =
      pass_entries
      |> Enum.map(fn [k | _] -> k end)
      |> MapSet.new()
      |> pass_valid_p1?()

    valid_p1? and Enum.all?(pass_entries, &valid_entry?/1)
  end

  @byr_range 1920..2002
  @iyr_range 2010..2020
  @eyr_range 2020..2030
  @hgt_cm_range 150..193
  @hgt_in_range 59..76
  @ecl_options MapSet.new(~w[amb blu brn gry grn hzl oth])

  defp valid_entry?(["byr", val]) do
    String.to_integer(val) in @byr_range
  end

  defp valid_entry?(["iyr", val]) do
    String.to_integer(val) in @iyr_range
  end

  defp valid_entry?(["eyr", val]) do
    String.to_integer(val) in @eyr_range
  end

  defp valid_entry?(["hgt", val]) do
    ~r/^(\d+)(cm|in)$/
    |> Regex.run(val, capture: :all_but_first)
    |> case do
      [height, "cm"] -> String.to_integer(height) in @hgt_cm_range
      [height, "in"] -> String.to_integer(height) in @hgt_in_range
      nil -> false
    end
  end

  defp valid_entry?(["hcl", val]) do
    Regex.match?(~r|^#[0-9a-f]{6}$|, val)
  end

  defp valid_entry?(["ecl", val]) do
    val in @ecl_options
  end

  defp valid_entry?(["pid", val]) do
    Regex.match?(~r|^\d{9}$|, val)
  end

  defp valid_entry?(["cid", _val]) do
    true
  end
end
