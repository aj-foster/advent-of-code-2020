defmodule Day10 do
  #
  # Read and Parse
  #

  defp input do
    File.stream!("10/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
  end

  #
  # Part One
  #

  @spec part_one :: number
  def part_one do
    input()
    |> Enum.sort()
    |> Enum.reduce({0, 0, 0}, fn current, {prev, ones, threes} ->
      case current - prev do
        1 -> {current, ones + 1, threes}
        3 -> {current, ones, threes + 1}
        _ -> {current, ones, threes}
      end
    end)
    # Add one to the threes because of the final jump to the device.
    |> (fn {_, ones, threes} -> ones * (threes + 1) end).()
  end

  #
  # Part Two
  #

  @doc """
  The critical idea for this part is this: when a number has a gap of 3 on either side of it, it
  cannot be removed under any circumstances. If we divide the entire list into sections between
  gaps of three, the first and last numbers in each sublist are guaranteed to always be present.
  We can then solve the much simpler problem of counting the ways of dealing with the smaller
  sublists and multiply the solutions together.
  """
  @spec part_two :: number
  def part_two do
    {reversed_chunked_list_minus_one, reversed_final_group, _final_number} =
      input()
      |> Enum.sort()
      |> Enum.reduce({[], [0], 0}, fn x, {chunked_list, sublist, prev} ->
        case x - prev do
          3 -> {[Enum.reverse(sublist) | chunked_list], [x], x}
          _ -> {chunked_list, [x | sublist], x}
        end
      end)

    Enum.reverse([Enum.reverse(reversed_final_group) | reversed_chunked_list_minus_one])
    |> Enum.map(&count/1)
    |> Enum.reduce(&*/2)
  end

  # Brute force counting of possibilities. This WILL NOT finish in a reasonable amount of time if
  # applied to the entire list. It must be applied to small subsections.
  #
  @spec count([integer]) :: integer
  defp count(list)

  # Look for a single "droppable" number. Count with and without it.
  defp count([a, b, c | rest]) when c - a <= 3, do: count([a, c | rest]) + count([b, c | rest])

  # In any other case, continue recursively.
  defp count([_a, b, c | rest]), do: count([b, c | rest])
  defp count([_, _]), do: 1
  defp count([_]), do: 1
end
