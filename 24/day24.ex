defmodule Day24 do
  #
  # Read and Parse
  #

  defp input do
    File.stream!("24/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_directions/1)
  end

  defp parse_directions(directions) do
    directions
    |> String.codepoints()
    |> parse_direction([])
  end

  defp parse_direction(["e" | rest], dirs), do: parse_direction(rest, [:east | dirs])
  defp parse_direction(["s", "e" | rest], dirs), do: parse_direction(rest, [:southeast | dirs])
  defp parse_direction(["s", "w" | rest], dirs), do: parse_direction(rest, [:southwest | dirs])
  defp parse_direction(["w" | rest], dirs), do: parse_direction(rest, [:west | dirs])
  defp parse_direction(["n", "w" | rest], dirs), do: parse_direction(rest, [:northwest | dirs])
  defp parse_direction(["n", "e" | rest], dirs), do: parse_direction(rest, [:northeast | dirs])
  defp parse_direction([], dirs), do: Enum.reverse(dirs)

  # defp reduce_directions(directions)

  # # Opposites cancel.
  # defp reduce_directions([:east, :west | rest]), do: reduce_directions(rest)
  # defp reduce_directions([:northeast, :southwest | rest]), do: reduce_directions(rest)
  # defp reduce_directions([:northwest, :southeast | rest]), do: reduce_directions(rest)
  # defp reduce_directions([:west, :east | rest]), do: reduce_directions(rest)
  # defp reduce_directions([:southwest, :northeast | rest]), do: reduce_directions(rest)
  # defp reduce_directions([:southeast, :northwest | rest]), do: reduce_directions(rest)

  # #
  # defp reduce_directions([:east, :northwest | rest]), do: reduce_directions([:northeast | rest])
  # defp reduce_directions([:east, :southwest | rest]), do: reduce_directions([:southeast | rest])
  # defp reduce_directions([:southeast, :west | rest]), do: reduce_directions([:southwest | rest])
  # defp reduce_directions([:southeast, :west | rest]), do: reduce_directions([:southwest | rest])

  #
  # Part One
  #

  @directions [:east, :southeast, :southwest, :west, :northwest, :northeast]
  # @max_tile 1386
  # @max_tile 2000
  @max_tile 30_000

  def part_one do
    first_tile = make_ref()

    first_adjacencies =
      Enum.reduce(@directions, [], fn dir, list -> [{first_tile, dir} | list] end)

    adjacencies = map_adjacencies(%{}, first_adjacencies)

    input()
    |> Enum.map(fn directions -> find_tile(directions, adjacencies, first_tile) end)
    |> Enum.sort()
    |> remove_even_duplicates()
    |> Enum.count()
  end

  defp remove_even_duplicates([a, a | rest]), do: remove_even_duplicates(rest)
  defp remove_even_duplicates([a, b | rest]), do: [a | remove_even_duplicates([b | rest])]
  defp remove_even_duplicates([a]), do: [a]
  defp remove_even_duplicates([]), do: []

  defp map_adjacencies(map, _queue) when map_size(map) >= @max_tile * 12, do: map

  defp map_adjacencies(map, [{tile, direction} | rest]) do
    if Map.get(map, {tile, direction}) do
      map_adjacencies(map, rest)
    else
      new_tile = make_ref()
      new_adjacencies = Enum.reduce(@directions, [], fn dir, list -> [{new_tile, dir} | list] end)

      map
      |> Map.put({tile, direction}, new_tile)
      |> Map.put({new_tile, opposite(direction)}, tile)
      |> maybe_put_counterclockwise_neighbor({tile, direction}, new_tile)
      |> maybe_put_clockwise_neighbor({tile, direction}, new_tile)
      |> map_adjacencies(rest ++ new_adjacencies)
    end
  end

  defp maybe_put_counterclockwise_neighbor(map, {tile, direction}, new_tile) do
    case Map.get(map, {tile, counterclockwise(direction)}) do
      nil ->
        map

      neighbor ->
        map
        |> Map.put({neighbor, counterclockwise(opposite(counterclockwise(direction)))}, new_tile)
        |> Map.put({new_tile, clockwise(opposite(direction))}, neighbor)
    end
  end

  defp maybe_put_clockwise_neighbor(map, {tile, direction}, new_tile) do
    case Map.get(map, {tile, clockwise(direction)}) do
      nil ->
        map

      neighbor ->
        map
        |> Map.put({neighbor, clockwise(opposite(clockwise(direction)))}, new_tile)
        |> Map.put({new_tile, counterclockwise(opposite(direction))}, neighbor)
    end
  end

  defp opposite(:east), do: :west
  defp opposite(:southeast), do: :northwest
  defp opposite(:southwest), do: :northeast
  defp opposite(:west), do: :east
  defp opposite(:northwest), do: :southeast
  defp opposite(:northeast), do: :southwest

  def clockwise(direction) do
    @directions
    |> Stream.cycle()
    |> Stream.drop_while(&(&1 != direction))
    |> Stream.drop(1)
    |> Enum.take(1)
    |> List.first()
  end

  def counterclockwise(direction) do
    @directions
    |> Enum.reverse()
    |> Stream.cycle()
    |> Stream.drop_while(&(&1 != direction))
    |> Stream.drop(1)
    |> Enum.take(1)
    |> List.first()
  end

  defp find_tile([direction | rest], adjacencies, current) do
    next = Map.fetch!(adjacencies, {current, direction})
    find_tile(rest, adjacencies, next)
  end

  defp find_tile([], _adjacencies, current), do: current

  #
  # Part Two
  #

  def part_two do
    first_tile = make_ref()

    first_adjacencies =
      Enum.reduce(@directions, [], fn dir, list -> [{first_tile, dir} | list] end)

    adjacencies = map_adjacencies(%{}, first_adjacencies)

    black_tiles =
      input()
      |> Enum.map(fn directions -> find_tile(directions, adjacencies, first_tile) end)
      |> Enum.sort()
      |> remove_even_duplicates()
      |> MapSet.new()

    day(black_tiles, adjacencies)
  end

  defp day(tiles, adjacencies, day \\ 0)
  defp day(tiles, _adjacencies, 100), do: MapSet.size(tiles)

  defp day(tiles, adjacencies, day) do
    IO.inspect(MapSet.size(tiles), label: "Day #{day}")

    next_to_black_tile =
      Enum.map(tiles, fn tile ->
        @directions
        |> Enum.map(fn dir -> Map.get(adjacencies, {tile, dir}) end)
        |> Enum.reject(&is_nil/1)
        |> Enum.reject(fn tile -> MapSet.member?(tiles, tile) end)
      end)
      |> List.flatten()
      |> MapSet.new()

    new_black_tiles =
      Enum.filter(next_to_black_tile, fn tile ->
        @directions
        |> Enum.count(fn dir ->
          a = Map.fetch!(adjacencies, {tile, dir})
          MapSet.member?(tiles, a)
        end)
        |> case do
          2 -> true
          _ -> false
        end
      end)
      |> MapSet.new()

    tiles =
      Enum.filter(tiles, fn tile ->
        @directions
        |> Enum.count(fn dir ->
          a = Map.fetch!(adjacencies, {tile, dir})
          MapSet.member?(tiles, a)
        end)
        |> case do
          1 -> true
          2 -> true
          _ -> false
        end
      end)
      |> MapSet.new()

    day(MapSet.union(tiles, new_black_tiles), adjacencies, day + 1)
  end
end
