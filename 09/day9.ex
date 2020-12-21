defmodule Day9 do
  #
  # Read and Parse
  #

  defp input do
    File.stream!("09/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
  end

  #
  # Part One
  #

  @spec part_one :: integer
  def part_one do
    Enum.reduce_while(input(), {[], []}, &search_for_sum/2)
  end

  defp search_for_sum(num, {last_25, cross}) do
    if length(last_25) == 25 do
      case num in List.flatten(cross) do
        true ->
          last_25 = Enum.take([num | last_25], 25)

          cross =
            for x <- last_25, y <- last_25 do
              x + y
            end

          {:cont, {last_25, cross}}

        false ->
          {:halt, num}
      end
    else
      last_25 = Enum.take([num | last_25], 25)

      cross =
        for x <- last_25, y <- last_25 do
          x + y
        end

      {:cont, {last_25, cross}}
    end
  end

  #
  # Part Two
  #

  @target 258_585_477

  @spec part_two :: number
  def part_two do
    Enum.reduce_while(input(), [], &stuff2/2)
  end

  defp stuff2(num, range) do
    sum = Enum.reduce(range, 0, &+/2)

    if sum == @target do
      {:halt, Enum.min(range) + Enum.max(range)}
    else
      if sum > @target do
        {_, range} = List.pop_at(range, -1)
        stuff2(num, range)
      else
        range = [num | range]
        {:cont, range}
      end
    end
  end
end
