defmodule Day15 do
  def part_one do
    File.read!("15/input.txt")
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.reverse()
    |> stuff()
  end

  defp stuff(list, length \\ nil)
  defp stuff([latest | _], 2020), do: latest

  defp stuff([latest | rest], length) do
    length = length || length(rest) + 1

    case Enum.find_index(rest, &(&1 == latest)) do
      nil ->
        stuff([0, latest | rest], length + 1)

      x ->
        stuff([x + 1, latest | rest], length + 1)
    end
  end

  def part_two do
    input =
      File.read!("15/input.txt")
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    last = List.last(input)

    input
    |> Enum.with_index()
    |> Enum.into(%{})
    |> Map.delete(last)
    |> stuff2(last)
  end

  defp stuff2(index, last, step \\ nil)
  defp stuff2(index, last, nil), do: stuff2(index, last, map_size(index))
  defp stuff2(_index, last, 29_999_999), do: last

  defp stuff2(index, last, step) do
    case index[last] do
      nil ->
        index = Map.put(index, last, step)
        stuff2(index, 0, step + 1)

      x ->
        index = Map.put(index, last, step)
        stuff2(index, step - x, step + 1)
    end
  end
end
