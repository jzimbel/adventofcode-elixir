defmodule AdventOfCode.Solution.Year2023.Day13 do
  alias AdventOfCode.Math

  def part1(input), do: solve(input, _smudge_count = 0)
  def part2(input), do: solve(input, _smudge_count = 1)

  defp solve(input, smudge_count) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.map(&find_and_score_line_of_symmetry(&1, smudge_count))
    |> Enum.sum()
  end

  defp find_and_score_line_of_symmetry(lines, smudge_count) do
    case find_symmetry(lines, smudge_count) do
      row when is_integer(row) -> 100 * row
      :error -> find_symmetry(transpose(lines), smudge_count)
    end
  end

  defp transpose(lines) do
    line_len = byte_size(hd(lines))
    Enum.map(0..(line_len - 1)//1, fn i -> Enum.into(lines, "", &binary_part(&1, i, 1)) end)
  end

  defp find_symmetry(lines, smudge_count) do
    [h | t] = Enum.map(lines, &line_to_int/1)
    find_symmetry([h], t, smudge_count)
  end

  defp find_symmetry(_, [], _), do: :error

  defp find_symmetry(l, r, smudge_count) do
    case count_smudges(l, r) do
      ^smudge_count -> length(l)
      _ -> find_symmetry([hd(r) | l], tl(r), smudge_count)
    end
  end

  defp count_smudges(l, r) do
    Enum.reduce_while(Enum.zip(l, r), _smudge_count = 0, fn
      {n, n}, c -> {:cont, c}
      {n1, n2}, c -> if Math.pow2?(Bitwise.bxor(n1, n2)), do: {:cont, c + 1}, else: {:halt, nil}
    end)
  end

  defp line_to_int(line) do
    Integer.undigits(for(<<char <- line>>, do: if(char == ?., do: 0, else: 1)), 2)
  end
end
