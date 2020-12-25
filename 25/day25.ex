defmodule Day25 do
  #
  # Read and Parse
  #

  @spec input :: {pos_integer, pos_integer}
  defp input do
    [card_pk, door_pk] =
      File.read!("25/input.txt")
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)

    {card_pk, door_pk}
  end

  #
  # Part One
  #

  @doc """
  Brute force! In get_loop_size/1 we keep trying loop sizes until we find the right one. Then, in
  transform/2, we use the loop size to calculate the encryption key. We do this on both sides (the
  card and the door) and compare the answers, since the solution is relatively quick to find.
  """
  @spec part_one :: pos_integer
  def part_one do
    {card_pk, door_pk} = input()

    key_from_card =
      get_loop_size(card_pk)
      |> IO.inspect(label: "Card Loop Size")
      |> transform(door_pk)
      |> IO.inspect(label: "Encryption Key, According to Card")

    key_from_door =
      get_loop_size(door_pk)
      |> IO.inspect(label: "Door Loop Size")
      |> transform(card_pk)
      |> IO.inspect(label: "Encryption Key, According to Door")

    if key_from_card == key_from_door do
      key_from_card
    else
      raise "Something has gone wrong"
    end
  end

  # Try increasing loop sizes until we find one that works. There's no guarantee that this will
  # terminate, but we have faith in the AoC creator's choice of numbers.
  #
  @spec get_loop_size(pos_integer, pos_integer, non_neg_integer) :: pos_integer
  defp get_loop_size(public_key, current \\ 1, loop \\ 0)
  defp get_loop_size(public_key, current, loop) when current == public_key, do: loop

  defp get_loop_size(public_key, current, loop) do
    current = rem(current * 7, 20_201_227)
    get_loop_size(public_key, current, loop + 1)
  end

  # Arguments have been moved around here to promote piping and avoid passing defaults.
  @spec transform(non_neg_integer, pos_integer, pos_integer) :: pos_integer
  defp transform(loops_remaining, subject, current \\ 1)
  defp transform(0, _subject, current), do: current

  defp transform(loop, subject, current) do
    current = rem(current * subject, 20_201_227)
    transform(loop - 1, subject, current)
  end
end
