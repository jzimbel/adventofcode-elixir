defmodule AdventOfCode.CharSpaceTest do
  use ExUnit.Case

  require Integer
  import AdventOfCode.CharSpace.ThreeDim

  setup_all do
    [
      input: """
      ..#.#
      #....
      ..#..
      #####
      ##.#.
      """
    ]
  end

  test "at/2", %{input: input} do
    char_space = from_input(input, ?!)

    assert at(char_space, {2, 0, 0}) == ?#
    assert at(char_space, {1, 1, 0}) == ?.
    assert at(char_space, {1, 1, 1}) == ?!
    assert at(char_space, {100, -50, 8}) == ?!
  end

  test "map/2", %{input: input} do
    char_space = from_input(input)

    result =
      map(char_space, fn
        {{x, y, z}, ?.} when x in 0..3 and y in 0..3 and z in -1..0 -> ?#
        {{x, y, z}, _} when x in 0..3 and y in 0..3 and z in -1..0 -> ?.
        {_, char} -> char
      end)

    assert at(result, {0, 0, 0}) == ?#
    assert at(result, {0, 1, 0}) == ?.
    assert at(result, {2, 1, -1}) == ?#
    assert at(result, {3, 4, 0}) == ?#
    assert count_chars(result, ?#) == 30
  end

  test "count_chars/2", %{input: input} do
    char_space = from_input(input)

    assert count_chars(char_space, ?#) == 12
    assert count_chars(char_space, ?.) == :infinity
  end

  test "adjacent_values/2", %{input: input} do
    char_space = from_input(input)

    result = adjacent_values(char_space, {0, 4, 0})

    assert Enum.frequencies(result) == %{?# => 3, ?. => 23}
  end
end
