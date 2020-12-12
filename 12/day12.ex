defmodule Day12 do
  #
  # Read and Parse
  #

  defp input do
    File.stream!("12/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn
      <<"N", rest::binary>> -> {:north, String.to_integer(rest)}
      <<"S", rest::binary>> -> {:south, String.to_integer(rest)}
      <<"E", rest::binary>> -> {:east, String.to_integer(rest)}
      <<"W", rest::binary>> -> {:west, String.to_integer(rest)}
      <<"L", rest::binary>> -> {:left, String.to_integer(rest)}
      <<"R", rest::binary>> -> {:right, String.to_integer(rest)}
      <<"F", rest::binary>> -> {:forward, String.to_integer(rest)}
    end)
  end

  #
  # Part One
  #

  @doc """
  In part one we reduce the directions using an accumulator that holds the current direction of the
  ship and its x,y coordinates. We'll treat North as the +y direction and East as +x.

  An old professor once referred to the "Manhattan distance" as a "cab-driver [distance]", a
  tongue-in-cheek reference to the idea that a cab driver would take a slightly longer route to
  get paid more.
  """
  @spec part_one :: number
  def part_one do
    input()
    # Accumulator: {direction, ship x, ship y}
    |> Enum.reduce({:east, 0, 0}, &navigate/2)
    |> (fn {_, x, y} -> abs(x) + abs(y) end).()
  end

  # Moving the ship in a cardinal direction means translating the relevant coordinate.
  #
  defp navigate({:north, num}, {direction, x, y}), do: {direction, x, y + num}
  defp navigate({:south, num}, {direction, x, y}), do: {direction, x, y - num}
  defp navigate({:east, num}, {direction, x, y}), do: {direction, x + num, y}
  defp navigate({:west, num}, {direction, x, y}), do: {direction, x - num, y}

  # Moving forward means moving the ship in whatever direction it happens to be facing.
  #
  defp navigate({:forward, num}, {dir, x, y}), do: navigate({dir, num}, {dir, x, y})

  # Rotating the ship changes only the direction; this needs additional logic.
  #
  defp navigate({rotate, num}, {direction, x, y}), do: {turn_ship(direction, rotate, num), x, y}

  # Using `Stream.cycle/1` gives an infinite cycle of the directions. We can skip ahead to the
  # current direction and then drop as many turns as we need to find the new direction.
  #
  defp turn_ship(dir, :left, amount) do
    turns = div(amount, 90)

    Stream.cycle([:north, :west, :south, :east])
    |> Stream.drop_while(&(&1 != dir))
    |> Stream.drop(turns)
    |> Enum.at(0)
  end

  defp turn_ship(dir, :right, amount) do
    turns = div(amount, 90)

    Stream.cycle([:north, :east, :south, :west])
    |> Stream.drop_while(&(&1 != dir))
    |> Stream.drop(turns)
    |> Enum.at(0)
  end

  #
  # Part Two
  #

  @doc """
  Largely similar to part one, this time we reduce the instructions with an accumulator that
  contains the position of the ship and the (relative) position of the waypoint.
  """
  @spec part_two :: number
  def part_two do
    input()
    # Accumulator: {ship direction, ship x, ship y, waypoint x, waypoint y}
    |> Enum.reduce({0, 0, 10, 1}, &nav_by_waypoint/2)
    |> (fn {ship_x, ship_y, _, _} -> abs(ship_x) + abs(ship_y) end).()
  end

  # Moving the waypoint uses the same translation idea as above.
  #
  defp nav_by_waypoint({:north, num}, {x, y, wx, wy}), do: {x, y, wx, wy + num}
  defp nav_by_waypoint({:south, num}, {x, y, wx, wy}), do: {x, y, wx, wy - num}
  defp nav_by_waypoint({:east, num}, {x, y, wx, wy}), do: {x, y, wx + num, wy}
  defp nav_by_waypoint({:west, num}, {x, y, wx, wy}), do: {x, y, wx - num, wy}

  # Moving the ship involves applying the waypoint values to the ship's coordinates.
  #
  defp nav_by_waypoint({:forward, num}, {x, y, wx, wy}), do: {x + wx * num, y + wy * num, wx, wy}

  # Handle rotation of the waypoint recursively. Here's the base case.
  #
  defp nav_by_waypoint({direction, 0}, state)
       when direction in [:left, :right],
       do: state

  # Rotating left means applying the matrix:
  #
  #  ( 0 -1 ) ( wx )  ->  ( -wy )
  #  ( 1  0 ) ( wy )  ->  (  wx )
  #
  defp nav_by_waypoint({:left, num}, {x, y, wx, wy}),
    do: nav_by_waypoint({:left, num - 90}, {x, y, -wy, wx})

  # Rotating right means applying the matrix:
  #
  #  ( 0  1 ) ( wx )  ->  (  wy )
  #  ( -1 0 ) ( wy )  ->  ( -wx )
  #
  defp nav_by_waypoint({:right, num}, {x, y, wx, wy}),
    do: nav_by_waypoint({:right, num - 90}, {x, y, wy, -wx})
end
