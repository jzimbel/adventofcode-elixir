defmodule AdventOfCode.Solution.Year2021.Day18 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.reduce(&add(&2, &1))
    |> magnitude()
  end

  def part2(input) do
    input
    |> parse_input()
    |> then(fn numbers ->
      indexed_numbers = Enum.with_index(numbers)

      for {sn1, i} <- indexed_numbers,
          {sn2, j} <- indexed_numbers,
          i != j,
          do: {sn1, sn2}
    end)
    |> Enum.map(fn {sn1, sn2} -> add(sn1, sn2) end)
    |> Enum.map(&magnitude/1)
    |> Enum.max()
  end

  def add(sn1, sn2) do
    reduce({sn1, sn2})
  end

  def reduce(sn) do
    with :ok <- try_explode(sn),
         :ok <- try_split(sn) do
      sn
    else
      {:explode, sn, _, _} -> reduce(sn)
      {:split, sn} -> reduce(sn)
    end
  end

  def try_explode(sn, level \\ 0)

  def try_explode({l, r}, 4) do
    {:explode, 0, {l, false}, {r, false}}
  end

  def try_explode({l, r}, level) do
    with {:l, :ok} <- {:l, try_explode(l, level + 1)},
         {:r, :ok} <- {:r, try_explode(r, level + 1)} do
      :ok
    else
      {:l, {:explode, l, l_explode, r_explode}} ->
        {r, r_explode} = put_explode(r, r_explode, :l)
        {:explode, {l, r}, l_explode, r_explode}

      {:r, {:explode, r, l_explode, r_explode}} ->
        {l, l_explode} = put_explode(l, l_explode, :r)
        {:explode, {l, r}, l_explode, r_explode}
    end
  end

  def try_explode(_n, _level), do: :ok

  def try_split({l, r}) do
    with {:l, :ok} <- {:l, try_split(l)},
         {:r, :ok} <- {:r, try_split(r)} do
      :ok
    else
      {:l, {:split, l}} -> {:split, {l, r}}
      {:r, {:split, r}} -> {:split, {l, r}}
    end
  end

  def try_split(n) when n >= 10 do
    {:split, {div(n, 2), ceil(n / 2)}}
  end

  def try_split(_n), do: :ok

  def put_explode(sn, {explode_n, true}, _), do: {sn, {explode_n, true}}

  def put_explode(sn, {explode_n, false}, side) do
    put_explode(sn, explode_n, side)
  end

  def put_explode({l, r}, explode_n, :l) do
    {l, record} = put_explode(l, explode_n, :l)
    {{l, r}, record}
  end

  def put_explode({l, r}, explode_n, :r) do
    {r, record} = put_explode(r, explode_n, :r)
    {{l, r}, record}
  end

  def put_explode(n, explode_n, _), do: {n + explode_n, {explode_n, true}}

  def magnitude({l, r}), do: 3 * magnitude(l) + 2 * magnitude(r)
  def magnitude(n), do: n

  def parse_input(input) do
    if safe?(input) do
      input
      |> String.replace(~w|[ ]|, fn
        "[" -> "{"
        "]" -> "}"
      end)
      |> String.split("\n", trim: true)
      |> Enum.map(&Code.eval_string/1)
      |> Enum.map(&elem(&1, 0))
    else
      raise "I ain't eval-ing that"
    end
  end

  def safe?(input), do: Regex.match?(~r/^[\[\]\d,\n]+$/, input)
end
