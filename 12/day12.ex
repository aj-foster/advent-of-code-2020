defmodule Day12 do
  def part_one do
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
    # {direction, ship x, ship y}
    |> Enum.reduce({:east, 0, 0}, &reduce_instructions/2)
    |> (fn {_, x, y} -> abs(x) + abs(y) end).()
  end

  defp reduce_instructions({:north, num}, {direction, x, y}), do: {direction, x, y + num}
  defp reduce_instructions({:south, num}, {direction, x, y}), do: {direction, x, y - num}
  defp reduce_instructions({:east, num}, {direction, x, y}), do: {direction, x + num, y}
  defp reduce_instructions({:west, num}, {direction, x, y}), do: {direction, x - num, y}

  defp reduce_instructions({:forward, num}, {direction, x, y}),
    do: reduce_instructions({direction, num}, {direction, x, y})

  defp reduce_instructions({l_or_r, num}, {direction, x, y}),
    do: {change_direction(direction, l_or_r, num), x, y}

  defp change_direction(dir, :left, amount) do
    turns = div(amount, 90)

    Stream.cycle([:north, :west, :south, :east])
    |> Stream.drop_while(&(&1 != dir))
    |> Stream.drop(turns)
    |> Enum.at(0)
  end

  defp change_direction(dir, :right, amount) do
    turns = div(amount, 90)

    Stream.cycle([:north, :east, :south, :west])
    |> Stream.drop_while(&(&1 != dir))
    |> Stream.drop(turns)
    |> Enum.at(0)
  end

  def part_two do
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
    # {ship direction, ship x, ship y, waypoint x, waypoint y}
    |> Enum.reduce({0, 0, 10, 1}, &reduce_instructions2/2)
    |> (fn {ship_x, ship_y, _, _} -> abs(ship_x) + abs(ship_y) end).()
  end

  defp reduce_instructions2({:north, num}, {x, y, wx, wy}), do: {x, y, wx, wy + num}
  defp reduce_instructions2({:south, num}, {x, y, wx, wy}), do: {x, y, wx, wy - num}
  defp reduce_instructions2({:east, num}, {x, y, wx, wy}), do: {x, y, wx + num, wy}
  defp reduce_instructions2({:west, num}, {x, y, wx, wy}), do: {x, y, wx - num, wy}

  defp reduce_instructions2({:forward, num}, {x, y, wx, wy}),
    do: {x + wx * num, y + wy * num, wx, wy}

  defp reduce_instructions2({direction, 0}, state) when direction in [:left, :right], do: state

  defp reduce_instructions2({:left, num}, {x, y, wx, wy}),
    do: reduce_instructions2({:left, num - 90}, {x, y, -wy, wx})

  defp reduce_instructions2({:right, num}, {x, y, wx, wy}),
    do: reduce_instructions2({:right, num - 90}, {x, y, wy, -wx})
end
