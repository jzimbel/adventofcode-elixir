defmodule AdventOfCode.Solution.Year2022.Day07 do
  defmodule Dir do
    @type t :: %__MODULE__{
            size: non_neg_integer(),
            dirs: %{String.t() => t()}
          }
    defstruct size: 0, dirs: %{}

    @spec sizes(t()) :: list(non_neg_integer())
    def sizes(d) do
      [d.size] ++ Enum.flat_map(Map.values(d.dirs), &sizes/1)
    end
  end

  defmodule Zipper.Context do
    @type t :: %__MODULE__{
            name: String.t(),
            siblings_size: non_neg_integer(),
            dir_siblings: %{String.t() => Dir.t()}
          }
    defstruct [:name, :siblings_size, :dir_siblings]
  end

  defmodule Zipper do
    alias Zipper.Context

    @type t :: %__MODULE__{
            focus: Dir.t(),
            context: list(Context.t())
          }
    defstruct focus: %Dir{}, context: []

    @spec to_dir(t()) :: Dir.t()
    def to_dir(z) do
      Enum.reduce(z.context, z.focus, &rebuild_parent/2)
    end

    @spec add_dir(t(), String.t()) :: t()
    def add_dir(z, name) do
      update_in(z.focus.dirs, &Map.put_new(&1, name, %Dir{}))
    end

    @spec add_size(t(), integer) :: t()
    def add_size(z, size) do
      update_in(z.focus.size, &(&1 + size))
    end

    @spec down(t(), String.t()) :: t()
    def down(z, name) do
      %__MODULE__{
        focus: Map.fetch!(z.focus.dirs, name),
        context: [make_context(z.focus, name) | z.context]
      }
    end

    @spec up(t()) :: t()
    def up(%{context: [context | rest]} = z) do
      %__MODULE__{context: rest, focus: rebuild_parent(context, z.focus)}
    end

    defp make_context(dir, cd_name) do
      %Context{
        name: cd_name,
        siblings_size: dir.size - dir.dirs[cd_name].size,
        dir_siblings: Map.delete(dir.dirs, cd_name)
      }
    end

    defp rebuild_parent(context, from_dir) do
      %Dir{
        size: context.siblings_size + from_dir.size,
        dirs: Map.put_new(context.dir_siblings, context.name, from_dir)
      }
    end
  end

  def part1(input) do
    input
    |> parse_fs()
    |> Dir.sizes()
    |> Enum.reject(&(&1 > 100_000))
    |> Enum.sum()
  end

  @capacity 70_000_000
  @min_needed 30_000_000

  def part2(input) do
    fs = parse_fs(input)

    unused_space = @capacity - fs.size
    min_to_delete = @min_needed - unused_space

    fs
    |> Dir.sizes()
    |> Enum.filter(&(&1 >= min_to_delete))
    |> Enum.min()
  end

  defp parse_fs(input) do
    input
    |> String.split("\n", trim: true)
    # Skip "$ cd /"
    |> Enum.drop(1)
    |> Enum.reduce(%Zipper{}, &process_line/2)
    |> Zipper.to_dir()
  end

  defp process_line("$ ls", z), do: z

  defp process_line("$ cd ..", z), do: Zipper.up(z)
  defp process_line("$ cd " <> dir_name, z), do: Zipper.down(z, dir_name)

  defp process_line("dir " <> dir_name, z) do
    Zipper.add_dir(z, dir_name)
  end

  defp process_line(file_line, z) do
    {size, _} = Integer.parse(file_line)
    Zipper.add_size(z, size)
  end
end
