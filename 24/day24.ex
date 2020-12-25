defmodule Day24 do
  @type tile :: reference
  @type direction :: :east | :southeast | :southwest | :west | :northwest | :northeast
  @type adjacency_map :: %{{tile, direction} => tile}

  @directions [:east, :southeast, :southwest, :west, :northwest, :northeast]

  # For part one, we need ~22 layers of hexagons out from the center due to the length of the
  # longest set of directions. That translates to approximately 1386 tiles.
  #
  # @max_tile 1386

  # For part two, we need ~122 layers of hexagons out from the center due to the length of the
  # longest set of directions plus 100 days of potential outward expansion. That translates to
  # approximately 30,000 hexagons.
  #
  # Ideally we would calculate tiles and their adjacencies on-the-fly, but this will suffice.
  #
  @max_tile 30_000

  #
  # Read and Parse
  #

  @spec input :: Enumerable.t()
  defp input do
    File.stream!("24/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_directions/1)
  end

  @spec parse_directions(String.t(), [direction]) :: [direction]
  defp parse_directions(string, directions \\ [])
  defp parse_directions("e" <> rest, dirs), do: parse_directions(rest, [:east | dirs])
  defp parse_directions("se" <> rest, dirs), do: parse_directions(rest, [:southeast | dirs])
  defp parse_directions("sw" <> rest, dirs), do: parse_directions(rest, [:southwest | dirs])
  defp parse_directions("w" <> rest, dirs), do: parse_directions(rest, [:west | dirs])
  defp parse_directions("nw" <> rest, dirs), do: parse_directions(rest, [:northwest | dirs])
  defp parse_directions("ne" <> rest, dirs), do: parse_directions(rest, [:northeast | dirs])
  defp parse_directions("", dirs), do: Enum.reverse(dirs)

  #
  # Part One
  #

  @doc """
  For part one, we want to find all of the flipped tiles and count those that have been flipped an
  odd number of times. Although inefficient, we can pre-compute a map of all adjacencies (one that
  maps {tile, direction} -> tile) we are likely to need based on the number of directions there are
  in each line.
  """
  @spec part_one :: non_neg_integer
  def part_one do
    {center_tile, adjacencies} = create_adjacency_map()

    input()
    |> Enum.map(fn directions -> find_tile(directions, adjacencies, center_tile) end)
    |> Enum.frequencies()
    |> Enum.count(fn {_tile, frequency} -> rem(frequency, 2) == 1 end)
  end

  @spec create_adjacency_map :: {tile, adjacency_map}
  defp create_adjacency_map do
    center_tile = make_ref()

    first_adjacencies =
      Enum.reduce(@directions, [], fn dir, list -> [{center_tile, dir} | list] end)

    adjacencies = map_adjacencies(%{}, first_adjacencies)

    {center_tile, adjacencies}
  end

  defp map_adjacencies(map, _queue) when map_size(map) >= @max_tile * 6, do: map

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

  defp find_tile([direction | rest], adjacencies, current) do
    next = Map.fetch!(adjacencies, {current, direction})
    find_tile(rest, adjacencies, next)
  end

  defp find_tile([], _adjacencies, current), do: current

  #
  # Part Two
  #

  @spec part_two :: non_neg_integer
  def part_two do
    first_tile = make_ref()

    first_adjacencies =
      Enum.reduce(@directions, [], fn dir, list -> [{first_tile, dir} | list] end)

    adjacencies = map_adjacencies(%{}, first_adjacencies)

    black_tiles =
      input()
      |> Enum.map(fn directions -> find_tile(directions, adjacencies, first_tile) end)
      |> Enum.frequencies()
      |> Enum.filter(fn {_tile, frequency} -> rem(frequency, 2) == 1 end)
      |> Enum.map(fn {tile, _frequency} -> tile end)
      |> MapSet.new()

    day(black_tiles, adjacencies)
  end

  defp day(tiles, adjacencies, day \\ 0)
  defp day(tiles, _adjacencies, 100), do: MapSet.size(tiles)

  defp day(tiles, adjacencies, day) do
    adjacent_to_black_tiles = find_adjacent_to_black(tiles, adjacencies)
    new_black_tiles = find_new_black_tiles(tiles, adjacent_to_black_tiles, adjacencies)
    tiles = find_tiles_remaining_black(tiles, adjacencies)

    day(MapSet.union(tiles, new_black_tiles), adjacencies, day + 1)
  end

  defp find_adjacent_to_black(black_tiles, adjacencies) do
    Enum.map(black_tiles, fn tile ->
      @directions
      |> Enum.map(fn dir -> Map.get(adjacencies, {tile, dir}) end)
      |> Enum.reject(&is_nil/1)
      |> Enum.reject(fn tile -> MapSet.member?(black_tiles, tile) end)
    end)
    |> List.flatten()
    |> MapSet.new()
  end

  defp find_new_black_tiles(black_tiles, adjacent_to_black_tiles, adjacencies) do
    Enum.filter(adjacent_to_black_tiles, fn tile ->
      @directions
      |> Enum.count(fn dir ->
        a = Map.fetch!(adjacencies, {tile, dir})
        MapSet.member?(black_tiles, a)
      end)
      |> case do
        2 -> true
        _ -> false
      end
    end)
    |> MapSet.new()
  end

  defp find_tiles_remaining_black(black_tiles, adjacencies) do
    Enum.filter(black_tiles, fn tile ->
      @directions
      |> Enum.count(fn dir ->
        a = Map.fetch!(adjacencies, {tile, dir})
        MapSet.member?(black_tiles, a)
      end)
      |> case do
        1 -> true
        2 -> true
        _ -> false
      end
    end)
    |> MapSet.new()
  end

  #
  # Helpers
  #

  # One way of mapping directions: manually with pattern matching.
  @spec opposite(direction) :: direction
  defp opposite(:east), do: :west
  defp opposite(:southeast), do: :northwest
  defp opposite(:southwest), do: :northeast
  defp opposite(:west), do: :east
  defp opposite(:northwest), do: :southeast
  defp opposite(:northeast), do: :southwest

  # Another way of mapping directions: using infinite cycles of directions.
  @spec clockwise(direction) :: direction
  defp clockwise(direction) do
    @directions
    |> Stream.cycle()
    |> Stream.drop_while(&(&1 != direction))
    |> Enum.at(1)
  end

  @spec counterclockwise(direction) :: direction
  defp counterclockwise(direction) do
    @directions
    |> Enum.reverse()
    |> Stream.cycle()
    |> Stream.drop_while(&(&1 != direction))
    |> Enum.at(1)
  end
end
