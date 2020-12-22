defmodule Day22 do
  def part_one do
    [one, two] =
      File.read!("22/input.txt")
      |> String.split("\n\n", trim: true)
      |> Enum.map(fn player ->
        String.split(player, "\n", trim: true)
        |> Enum.drop(1)
        |> Enum.map(&String.to_integer/1)
      end)

    round(one, two)
  end

  defp round([one | rest_one], [two | rest_two]) do
    if one > two do
      round(rest_one ++ [one, two], rest_two)
    else
      round(rest_one, rest_two ++ [two, one])
    end
  end

  defp round(one, []) do
    one
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {card, index}, sum -> sum + card * index end)
  end

  defp round([], two) do
    two
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {card, index}, sum -> sum + card * index end)
  end

  #
  # Part Two
  #

  def part_two do
    [one, two] =
      File.read!("22/input.txt")
      |> String.split("\n\n", trim: true)
      |> Enum.map(fn player ->
        String.split(player, "\n", trim: true)
        |> Enum.drop(1)
        |> Enum.map(&String.to_integer/1)
      end)

    recursive_round(one, two)
  end

  defp recursive_round(one, two, history \\ MapSet.new())

  defp recursive_round([one | rest_one] = one_all, [two | rest_two] = two_all, history) do
    IO.puts("Player 1: " <> Enum.join(one_all, ", "))
    IO.puts("Player 2: " <> Enum.join(two_all, ", "))

    cond do
      MapSet.member?(history, {one_all, two_all}) ->
        {:one, calculate_score(one_all)}

      one > length(rest_one) or two > length(rest_two) ->
        if one > two do
          recursive_round(
            rest_one ++ [one, two],
            rest_two,
            MapSet.put(history, {one_all, two_all})
          )
        else
          recursive_round(
            rest_one,
            rest_two ++ [two, one],
            MapSet.put(history, {one_all, two_all})
          )
        end

      true ->
        case recursive_round(
               Enum.slice(rest_one, 0..(one - 1)),
               Enum.slice(rest_two, 0..(two - 1))
             ) do
          {:one, _score} ->
            recursive_round(
              rest_one ++ [one, two],
              rest_two,
              MapSet.put(history, {one_all, two_all})
            )

          {:two, _score} ->
            recursive_round(
              rest_one,
              rest_two ++ [two, one],
              MapSet.put(history, {one_all, two_all})
            )
        end
    end
  end

  defp recursive_round(one, [], _history) do
    IO.puts("Win for Player 1")
    {:one, calculate_score(one)}
  end

  defp recursive_round([], two, _history) do
    IO.puts("Win for Player 2")
    {:two, calculate_score(two)}
  end

  defp calculate_score(deck) do
    deck
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {card, index}, sum -> sum + card * index end)
  end
end
