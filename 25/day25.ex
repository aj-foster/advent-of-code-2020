defmodule Day25 do
  def part_one do
    [card_pk, door_pk] =
      File.read!("25/input.txt")
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)

    card_loop_size =
      guess_loop_size(card_pk)
      |> IO.inspect(label: "Card Loop Size")

    door_loop_size =
      guess_loop_size(door_pk)
      |> IO.inspect(label: "Door Loop Size")

    transform(door_pk, 1, card_loop_size)
    |> IO.inspect()

    transform(card_pk, 1, door_loop_size)
    |> IO.inspect()
  end

  defp guess_loop_size(public_key, current \\ 1, loop \\ 0)
  defp guess_loop_size(public_key, current, loop) when current == public_key, do: loop

  defp guess_loop_size(public_key, current, loop) do
    current = rem(current * 7, 20_201_227)
    guess_loop_size(public_key, current, loop + 1)
  end

  defp transform(_public_key, current, 0), do: current

  defp transform(public_key, current, loop) do
    current = rem(current * public_key, 20_201_227)
    transform(public_key, current, loop - 1)
  end
end
