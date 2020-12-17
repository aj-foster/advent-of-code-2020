defmodule Day17 do
  require Day17Helper

  #
  # Read and Parse
  #

  @spec input :: [{number, number}]
  defp input do
    File.stream!("17/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.filter(fn {char, _x} -> char == "#" end)
      |> Enum.map(fn {_char, x} -> {x, y} end)
    end)
    |> Enum.to_list()
  end

  #
  # Part One
  #

  @doc """

  """
  @spec part_one :: non_neg_integer
  def part_one do
    input()
    |> Enum.map(fn {x, y} -> {x, y, 0} end)
    |> cycle_3d(6)
  end

  defp cycle_3d(active_blocks, 0), do: length(active_blocks)

  defp cycle_3d(active_blocks, round) do
    active_blocks
    |> Enum.reduce(%{}, fn {x, y, z}, adjacencies ->
      Day17Helper.off_by_ones_3d()
      |> Enum.reduce(adjacencies, fn {dx, dy, dz}, adjacencies ->
        Map.update(adjacencies, {x + dx, y + dy, z + dz}, 1, &(&1 + 1))
      end)
    end)
    |> Enum.reduce([], fn {{x, y, z}, adjacent_blocks}, new_active_blocks ->
      cond do
        adjacent_blocks == 3 and not Enum.member?(active_blocks, {x, y, z}) ->
          [{x, y, z} | new_active_blocks]

        adjacent_blocks in [2, 3] and Enum.member?(active_blocks, {x, y, z}) ->
          [{x, y, z} | new_active_blocks]

        true ->
          new_active_blocks
      end
    end)
    |> cycle_3d(round - 1)
  end

  #
  # Part Two
  #

  @spec part_two :: non_neg_integer
  def part_two do
    input()
    |> Enum.map(fn {x, y} -> {x, y, 0, 0} end)
    |> cycle_4d(6)
  end

  defp cycle_4d(active_blocks, 0), do: length(active_blocks)

  defp cycle_4d(active_blocks, round) do
    active_blocks
    |> Enum.reduce(%{}, fn {x, y, z, w}, adjacencies ->
      Day17Helper.off_by_ones_4d()
      |> Enum.reduce(adjacencies, fn {dx, dy, dz, dw}, adjacencies ->
        Map.update(adjacencies, {x + dx, y + dy, z + dz, w + dw}, 1, &(&1 + 1))
      end)
    end)
    |> Enum.reduce([], fn {{x, y, z, w}, adjacent_blocks}, new_active_blocks ->
      cond do
        adjacent_blocks == 3 and not Enum.member?(active_blocks, {x, y, z, w}) ->
          [{x, y, z, w} | new_active_blocks]

        adjacent_blocks in [2, 3] and Enum.member?(active_blocks, {x, y, z, w}) ->
          [{x, y, z, w} | new_active_blocks]

        true ->
          new_active_blocks
      end
    end)
    |> cycle_4d(round - 1)
  end
end
