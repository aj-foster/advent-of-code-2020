defmodule Day23 do
  def part_one do
    File.stream!("23/input.txt", [], 1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
    |> play_round()
  end

  defp play_round(cups, move \\ 0)

  defp play_round(cups, 100),
    do:
      Stream.cycle(cups)
      |> Stream.drop_while(&(&1 != 1))
      |> Stream.drop(1)
      |> Enum.take(8)
      |> Enum.join()

  defp play_round([current, one, two, three | rest], move) do
    picked = [one, two, three]
    destination = get_destination(current, picked)
    index = Enum.find_index(rest, &(&1 == destination))

    cups =
      (List.insert_at(rest, index + 1, picked) ++ [current])
      |> List.flatten()

    play_round(cups, move + 1)
  end

  @spec get_destination(number, [number]) :: number
  defp get_destination(current, picked) do
    cond do
      mod9(current - 1) not in picked ->
        mod9(current - 1)

      mod9(current - 2) not in picked ->
        mod9(current - 2)

      mod9(current - 3) not in picked ->
        mod9(current - 3)

      true ->
        mod9(current - 4)
    end
  end

  defp mod9(input) when input <= 0, do: input + 9
  defp mod9(input), do: input

  #
  #
  #

  def part_two do
    File.stream!("23/input.txt", [], 1)
    |> Stream.map(&String.to_integer/1)
    |> Stream.concat(10..1_000_000)
    |> Enum.to_list()
    |> build_map()
    |> play_large_round()
  end

  defp build_map(list, map \\ %{}, previous \\ 1_000_000)

  defp build_map([head | tail], map, previous) do
    build_map(tail, Map.put(map, previous, head), head)
  end

  defp build_map([], map, _previous), do: map

  defp play_large_round(cups, current \\ 1, move \\ 0)

  defp play_large_round(cups, _current, 10_000_000) do
    first = Map.fetch!(cups, 1) |> IO.inspect()
    second = Map.fetch!(cups, first) |> IO.inspect()

    first * second
  end

  defp play_large_round(cups, current, move) do
    one = Map.fetch!(cups, current)
    two = Map.fetch!(cups, one)
    three = Map.fetch!(cups, two)

    picked = [one, two, three]
    destination = get_destination2(current, picked)

    post_picked = Map.fetch!(cups, three)
    post_destination = Map.fetch!(cups, destination)

    cups =
      cups
      |> Map.put(destination, one)
      |> Map.put(three, post_destination)
      |> Map.put(current, post_picked)

    play_large_round(cups, post_picked, move + 1)
  end

  @spec get_destination2(number, [number]) :: number
  defp get_destination2(current, picked) do
    cond do
      mod1mil(current - 1) not in picked ->
        mod1mil(current - 1)

      mod1mil(current - 2) not in picked ->
        mod1mil(current - 2)

      mod1mil(current - 3) not in picked ->
        mod1mil(current - 3)

      true ->
        mod1mil(current - 4)
    end
  end

  defp mod1mil(input) when input <= 0, do: input + 1_000_000
  defp mod1mil(input), do: input
end
