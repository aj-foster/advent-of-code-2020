defmodule Day9 do
  def part_one do
    File.stream!("09/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.reduce_while({[], []}, &stuff/2)
  end

  defp stuff(num, {last_25, cross}) do
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

  def part_two do
    File.stream!("09/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.reduce_while([], &stuff2/2)
  end

  defp stuff2(num, range) do
    sum =
      if length(range) > 0 do
        Enum.reduce(range, &+/2)
      else
        0
      end

    if sum == 258_585_477 do
      IO.inspect(range)
      {:halt, Enum.min(range) + Enum.max(range)}
    else
      if sum > 258_585_477 do
        {_, range} = List.pop_at(range, -1)
        stuff2(num, range)
      else
        range = [num | range]
        {:cont, range}
      end
    end
  end
end
