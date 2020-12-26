defmodule Day15 do
  #
  # Read and Parse
  #

  @spec input :: [integer]
  defp input do
    File.read!("15/input.txt")
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  #
  # Part One
  #

  @doc """
  In part one, we have the benefit of being able to play rounds of the game inefficiently. We keep
  track of the list of previously mentioned numbers and use `Enum.at/2` to find the index of a
  number when necessary. This is inefficient because `Enum.at/2` will search the entire list until
  it finds a match or reaches the end. However, with 2020 or fewer elements, this is okay.
  """
  @spec part_one :: integer
  def part_one do
    input()
    |> Enum.reverse()
    |> play_round()
  end

  # Each recursive call represents one round of play.
  @spec play_round([integer], integer | nil) :: integer
  defp play_round(list, length \\ nil)

  # When 2020 numbers are present, we are done.
  defp play_round([latest | _], 2020), do: latest

  # A round of play involves searching for the previous mention of the latest number and adding
  # the appropriate number to the head of the list. For ease of use with lists, we operate on the
  # head of the list.
  #
  defp play_round([latest | rest], length) do
    # If this is the first time the function is called, update the length.
    length = length || length(rest) + 1

    case Enum.find_index(rest, &(&1 == latest)) do
      nil ->
        play_round([0, latest | rest], length + 1)

      x ->
        play_round([x + 1, latest | rest], length + 1)
    end
  end

  #
  # Part Two
  #

  @doc """
  In part two, we do not have the luxury of time for inefficient index lookups. Instead of a list
  of previously mentioned numbers, we can instead maintain a map of numbers -> time last mentioned.

  Note that we have to delete the last number from the indices map so that it can be the first
  number processed by the recursive function.
  """
  @spec part_two :: integer
  def part_two do
    input = input()
    last = List.last(input)

    input
    |> Enum.with_index()
    |> Enum.into(%{})
    |> Map.delete(last)
    |> play_round_efficiently(last)
  end

  # Each recursive call represents one round of play.
  @spec play_round_efficiently(%{integer => integer}, integer, integer | nil) :: integer
  defp play_round_efficiently(indices, last, step \\ nil)

  defp play_round_efficiently(indices, last, nil),
    do: play_round_efficiently(indices, last, map_size(indices) + 1)

  # After 30,000,000 rounds, we are done.
  defp play_round_efficiently(_indices, last, 30_000_000), do: last

  # We only add/update the indices map after we've checked for the data we need, so we're always
  # calling `Map.put/3` with a value of `step - 1`.
  #
  defp play_round_efficiently(indices, last, step) do
    case indices[last] do
      nil ->
        indices = Map.put(indices, last, step - 1)
        play_round_efficiently(indices, 0, step + 1)

      x ->
        indices = Map.put(indices, last, step - 1)
        play_round_efficiently(indices, step - x - 1, step + 1)
    end
  end
end
