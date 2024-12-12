defmodule AdventOfCode.Solution.Year2024.Day09 do
  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input) do
    input
    |> String.trim()
    |> :binary.bin_to_list()
    # Parse all digits in the string
    |> Enum.map(&(&1 - ?0))
    # Expand each digit to a file or free segment of the corresponding length
    |> Enum.flat_map_reduce({:file, 0}, fn
      n, {:file, i} -> {List.duplicate(i, n), {:free, i + 1}}
      n, {:free, i} -> {List.duplicate(:_, n), {:file, i}}
    end)
    |> then(fn {disk, _acc} -> disk end)
  end

  def part1(disk) do
    disk
    |> shift_files_left_p1()
    |> checksum()
  end

  def part2(disk) do
    disk
    |> shift_files_left_p2()
    |> checksum()
  end

  defp shift_files_left_p1(disk) do
    file_blocks =
      disk
      |> Enum.reject(&(&1 == :_))
      |> Enum.reverse()

    {new_disk, _} =
      disk
      # Since all file blocks are being compacted left,
      # we know the number of blocks needed ahead of time.
      |> Enum.take(length(file_blocks))
      |> Enum.map_reduce(file_blocks, fn
        # See a free block: emit a file block off the end
        :_, [file_block | file_blocks] -> {file_block, file_blocks}
        # See a file block: emit the file block
        file_block, file_blocks -> {file_block, file_blocks}
      end)

    new_disk
  end

  defp shift_files_left_p2(disk) do
    files =
      disk
      |> Enum.reject(&(&1 == :_))
      |> Enum.reverse()
      |> Enum.chunk_by(& &1)

    disk = Enum.chunk_by(disk, & &1)

    files
    |> Enum.reduce(disk, &relocate_file/2)
    |> List.flatten()
  end

  # "Head pattern". Matches a list with pattern `pat` as head and anything as tail.
  # hp(:foo) expands to [:foo | _]
  # hp(my_var) expands to [my_var | _], binding `my_var` to the head of a nonempty list
  defmacrop hp(pat), do: quote(do: [unquote(pat) | _])

  # Puts file at its new position (if one exists)
  # and then replaces its old position with free blocks using `clear_file`
  defp relocate_file(hp(id) = file, disk) do
    case disk do
      # Found a fit
      [hp(:_) = free | rest] when length(file) <= length(free) ->
        [file, Enum.drop(free, length(file)) | clear_file(id, rest)]

      # Too small
      [hp(:_) = free | rest] ->
        [free | relocate_file(file, rest)]

      # Reached the original file without finding a fit
      hp(hp(^id)) = disk ->
        disk

      # A different file
      [other_file | rest] ->
        [other_file | relocate_file(file, rest)]
    end
  end

  # Clears moved file, merging the newly-free segment with any adjacent free segments
  defp clear_file(id, disk) do
    case disk do
      # Found the file and it has free space both before and after it
      [hp(:_) = l_free, hp(^id) = file, hp(:_) = r_free | rest] ->
        [l_free ++ List.duplicate(:_, length(file)) ++ r_free | rest]

      # Found the file and it has free space before only
      [hp(:_) = l_free, hp(^id) = file | rest] ->
        [l_free ++ List.duplicate(:_, length(file)) | rest]

      # Found the file and it has free space after only
      [hp(^id) = file, hp(:_) = r_free | rest] ->
        [List.duplicate(:_, length(file)) ++ r_free | rest]

      # Found the file and it's surrounded by other files
      [hp(^id) = file | rest] ->
        [List.duplicate(:_, length(file)) | rest]

      # A free space or a different file
      [other | rest] ->
        [other | clear_file(id, rest)]
    end
  end

  defp checksum(disk) do
    disk
    |> Enum.with_index()
    |> Enum.reject(&match?({:_, _i}, &1))
    |> Enum.map(&Tuple.product/1)
    |> Enum.sum()
  end
end
