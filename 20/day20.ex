defmodule Day20 do
  import Bitwise

  #
  # Read and Parse
  #

  @spec input :: [{id :: integer, tile :: [String.t()]}]
  defp input do
    File.read!("20/input.txt")
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse/1)
  end

  defp parse(data) do
    lines = String.split(data, "\n", trim: true)
    <<"Tile ", id_and_colon::binary>> = List.first(lines)
    {id, ":"} = Integer.parse(id_and_colon)

    {id, Enum.drop(lines, 1)}
  end

  #
  # Part One
  #

  @doc """
  We can take each border, which will be a 10-character sequence of "." and "#" characters, and
  convert it into binary numbers by swapping periods for zeroes and hashes for ones. Though not
  explicitly stated, the border pairings are unique.

  The "standard" encoding of a border will be from the interior of the tile, reading left-to-right
  along the edge. Its matching border will be the reverse of this. We don't know if the matching
  tile will need to be flipped, so its matching border could have either value to start.

  The central idea for part one is that the corners will have two borders which have no pairings.
  Thus, if we calculae a map from encoded borders -> tile IDs, we're first interested in the borders
  with only 1 associated tile. Then, we're interested in the tiles that appear in this way a
  total of 4 times. Why 4 and not 2? We're putting both the border and its reversal in the map,
  so the two unmatched sides of a corner piece will be represented twice each.
  """
  @spec part_one :: non_neg_integer
  def part_one do
    input()
    |> Enum.map(&calculate_borders/1)
    |> Enum.reduce(%{}, &build_border_index/2)
    |> Enum.filter(fn {_border, ids} -> length(ids) == 1 end)
    |> Enum.map(fn {_border, [id]} -> id end)
    |> Enum.reduce(%{}, fn id, freq -> Map.update(freq, id, 1, &(&1 + 1)) end)
    |> Enum.reduce(%{}, fn {id, freq}, rev_freq ->
      Map.update(rev_freq, freq, [id], &[id | &1])
    end)
    |> Map.fetch!(4)
    |> Enum.reduce(&*/2)
  end

  defp calculate_borders({id, tile}) do
    top =
      List.first(tile)
      |> to_binary()

    top_flipped =
      List.first(tile)
      |> String.reverse()
      |> to_binary()

    right =
      Enum.map(tile, &String.last/1)
      |> Enum.join()
      |> to_binary()

    right_flipped =
      Enum.map(tile, &String.last/1)
      |> Enum.join()
      |> String.reverse()
      |> to_binary()

    bottom =
      List.last(tile)
      |> String.reverse()
      |> to_binary()

    bottom_flipped =
      List.last(tile)
      |> to_binary()

    left =
      Enum.map(tile, &String.first/1)
      |> Enum.join()
      |> String.reverse()
      |> to_binary()

    left_flipped =
      Enum.map(tile, &String.first/1)
      |> Enum.join()
      |> to_binary()

    {id,
     [{top, top_flipped}, {right, right_flipped}, {bottom, bottom_flipped}, {left, left_flipped}]}
  end

  defp to_binary(string) do
    string
    |> String.replace("#", "1")
    |> String.replace(".", "0")
    |> String.to_integer(2)
  end

  defp build_border_index(
         {id,
          [
            {top, top_flipped},
            {right, right_flipped},
            {bottom, bottom_flipped},
            {left, left_flipped}
          ]},
         index
       ) do
    index
    |> Map.update(top, [id], &[id | &1])
    |> Map.update(right, [id], &[id | &1])
    |> Map.update(bottom, [id], &[id | &1])
    |> Map.update(left, [id], &[id | &1])
    |> Map.update(top_flipped, [id], &[id | &1])
    |> Map.update(right_flipped, [id], &[id | &1])
    |> Map.update(bottom_flipped, [id], &[id | &1])
    |> Map.update(left_flipped, [id], &[id | &1])
  end

  #
  # Part Two
  #

  @spec part_two :: non_neg_integer
  def part_two do
    tiles = input()
    tile_map = Enum.into(tiles, %{})
    borders = Enum.map(tiles, &calculate_borders/1)
    border_map = Enum.into(borders, %{})
    adjacencies = Enum.reduce(borders, %{}, &build_border_index/2)

    arbitrarily_chosen_top_left_corner =
      adjacencies
      |> Enum.filter(fn {_border, ids} -> length(ids) == 1 end)
      |> Enum.map(fn {_border, [id]} -> id end)
      |> Enum.reduce(%{}, fn id, freq -> Map.update(freq, id, 1, &(&1 + 1)) end)
      |> Enum.reduce(%{}, fn {id, freq}, rev_freq ->
        Map.update(rev_freq, freq, [id], &[id | &1])
      end)
      |> Map.fetch!(4)
      |> List.first()

    {right_edge_of_first_corner, rotations} =
      border_map
      |> Map.fetch!(arbitrarily_chosen_top_left_corner)
      |> Enum.map(fn {border, _border_reversed} -> border end)
      |> Stream.cycle()
      |> Stream.with_index()
      |> Stream.drop_while(fn {border, _index} -> length(Map.fetch!(adjacencies, border)) == 2 end)
      |> Enum.find(fn {border, _index} -> length(Map.fetch!(adjacencies, border)) == 2 end)

    rotations = rem(rotations + 3, 4)

    first_row =
      map_tile(
        [{arbitrarily_chosen_top_left_corner, rotations, false}],
        right_edge_of_first_corner,
        adjacencies,
        border_map
      )

    rows = map_row([first_row], adjacencies, border_map)

    image =
      Enum.map(rows, fn row ->
        row = Enum.map(row, fn tile -> transform_tile(tile, tile_map) end)

        Enum.map(0..7, fn index ->
          Enum.map(row, fn tile ->
            Enum.at(tile, index)
          end)
          |> Enum.join()
        end)
      end)
      |> List.flatten()

    sea_creature =
      [
        "                  # ",
        "#    ##    ##    ###",
        " #  #  #  #  #  #   "
      ]
      |> Enum.map(fn line -> String.replace(line, "#", "1") end)
      |> Enum.map(fn line -> String.replace(line, " ", "0") end)
      |> Enum.map(fn line -> String.to_integer(line, 2) end)
      |> Enum.with_index()
      |> Enum.reduce(0, fn {num, index}, acc ->
        shift =
          Enum.at(image, 0)
          |> String.length()
          |> Kernel.*(2 - index)

        acc ||| num <<< shift
      end)

    non_noise = test(image, sea_creature) * 15

    hashes =
      Enum.join(image)
      |> String.codepoints()
      |> Enum.count(&(&1 == "#"))

    hashes - non_noise
  end

  defp test(sea, creature, count \\ 0)

  defp test([r1, r2, r3 | rest], creature, count) do
    count =
      [r1, r2, r3]
      |> Enum.join()
      |> String.replace("#", "1")
      |> String.replace(".", "0")
      |> IO.inspect()
      |> String.to_integer(2)
      |> attempt(creature, count)

    test([r2, r3 | rest], creature, count)
  end

  defp test(_, _, count), do: count

  defp attempt(sea, creature, count)
  defp attempt(sea, _, count) when sea == 0, do: count

  defp attempt(sea, creature, count)
       when (sea &&& creature) == creature,
       do: attempt(sea >>> 1, creature, count + 1)

  defp attempt(sea, creature, count), do: attempt(sea >>> 1, creature, count)

  defp transform_tile({id, rotations, flipped?}, tiles) do
    tile =
      Map.fetch!(tiles, id)
      |> Enum.map(fn line -> String.slice(line, 1..-2) end)
      |> Enum.slice(1..-2)

    rotated_tile =
      case rotations do
        0 ->
          tile

        1 ->
          Enum.map(0..(length(tile) - 1), fn index ->
            Enum.map(tile, fn line -> String.at(line, length(tile) - 1 - index) end)
            |> Enum.join()
          end)

        2 ->
          Enum.map(tile, &String.reverse/1)
          |> Enum.reverse()

        3 ->
          Enum.map(0..(length(tile) - 1), fn index ->
            Enum.reverse(tile)
            |> Enum.map(fn line -> String.at(line, index) end)
            |> Enum.join()
          end)
      end

    case flipped? do
      false -> rotated_tile
      true -> Enum.reverse(rotated_tile)
    end
  end

  defp map_tile([{prev_tile, _, _} | _] = tiles, border, adjacencies, border_map) do
    case Map.fetch!(adjacencies, border) do
      [^prev_tile] ->
        Enum.reverse(tiles)

      list ->
        [id] = Enum.filter(list, &(&1 != prev_tile))
        all_borders = Map.fetch!(border_map, id)
        rotations = Enum.find_index(all_borders, fn {b, rev} -> b == border or rev == border end)
        rotations = rem(rotations + 1, 4)

        next_borders =
          Stream.cycle(all_borders)
          |> Stream.drop_while(fn {b, rev} -> b != border and rev != border end)

        flipped =
          case Enum.at(next_borders, 0) do
            {^border, _} -> true
            {_, ^border} -> false
          end

        next_border =
          case flipped do
            false -> Enum.at(next_borders, 2) |> elem(0)
            true -> Enum.at(next_borders, 2) |> elem(1)
          end

        next_tile = {id, rotations, flipped}

        map_tile([next_tile | tiles], next_border, adjacencies, border_map)
    end
  end

  defp map_row(
         [[{prev_row_first_tile, rotations, flipped} | _] | _] = rows,
         adjacencies,
         border_map
       ) do
    rotations_to_bottom = if flipped, do: rotations, else: rotations + 2

    bottom_border =
      Map.fetch!(border_map, prev_row_first_tile)
      |> Enum.map(fn {border, _border_reversed} -> border end)
      |> Stream.cycle()
      |> Enum.at(rotations_to_bottom)

    case Map.fetch!(adjacencies, bottom_border) do
      [^prev_row_first_tile] ->
        Enum.reverse(rows)

      list ->
        [id] = Enum.filter(list, &(&1 != prev_row_first_tile))
        all_borders = Map.fetch!(border_map, id)

        next_borders =
          Stream.cycle(all_borders)
          |> Stream.drop_while(fn {b, rev} -> b != bottom_border and rev != bottom_border end)

        next_flipped =
          case Enum.at(next_borders, 0) do
            {^bottom_border, _} -> not flipped
            {_, ^bottom_border} -> flipped
          end

        rotations =
          Enum.find_index(all_borders, fn {b, rev} ->
            b == bottom_border or rev == bottom_border
          end)

        rotations = if next_flipped, do: rem(rotations + 2, 4), else: rotations

        next_border =
          case next_flipped do
            false -> Enum.at(next_borders, 1) |> elem(0)
            true -> Enum.at(next_borders, 3) |> elem(1)
          end

        next_tile = {id, rotations, next_flipped}
        next_row = map_tile([next_tile], next_border, adjacencies, border_map)
        map_row([next_row | rows], adjacencies, border_map)
    end
  end
end
