defmodule Day17 do
  def part_one do
    File.read!("17/input.txt")
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.filter(fn {char, _x} -> char == "#" end)
      |> Enum.map(fn {_char, x} -> {x, y, 0} end)
    end)
    |> cycle(6)
  end

  @off_by_ones_3d [
    {-1, -1, -1},
    {-1, -1, 0},
    {-1, -1, 1},
    {-1, 0, -1},
    {-1, 0, 0},
    {-1, 0, 1},
    {-1, 1, -1},
    {-1, 1, 0},
    {-1, 1, 1},
    {0, -1, -1},
    {0, -1, 0},
    {0, -1, 1},
    {0, 0, -1},
    {0, 0, 1},
    {0, 1, -1},
    {0, 1, 0},
    {0, 1, 1},
    {1, -1, -1},
    {1, -1, 0},
    {1, -1, 1},
    {1, 0, -1},
    {1, 0, 0},
    {1, 0, 1},
    {1, 1, -1},
    {1, 1, 0},
    {1, 1, 1}
  ]

  defp cycle(active_blocks, 0), do: length(active_blocks)

  defp cycle(active_blocks, round) do
    active_blocks
    |> Enum.reduce(%{}, fn {x, y, z}, adjacencies ->
      Enum.reduce(@off_by_ones_3d, adjacencies, fn {dx, dy, dz}, adjacencies ->
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
    |> IO.inspect(label: "after round = #{round}")
    |> cycle(round - 1)
  end

  def part_two do
    File.read!("17/input.txt")
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.filter(fn {char, _x} -> char == "#" end)
      |> Enum.map(fn {_char, x} -> {x, y, 0, 0} end)
    end)
    |> cycle2(6)
  end

  defp cycle2(active_blocks, 0), do: length(active_blocks)

  defp cycle2(active_blocks, round) do
    active_blocks
    |> Enum.reduce(%{}, fn {x, y, z, w}, adjacencies ->
      Enum.reduce(off_by_ones_4d(), adjacencies, fn {dx, dy, dz, dw}, adjacencies ->
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
    |> IO.inspect(label: "after round = #{round}")
    |> cycle2(round - 1)
  end

  defp off_by_ones_4d do
    for x <- [-1, 0, 1],
        y <- [-1, 0, 1],
        z <- [-1, 0, 1],
        w <- [-1, 0, 1],
        {x, y, z, w} != {0, 0, 0, 0} do
      {x, y, z, w}
    end
  end
end
