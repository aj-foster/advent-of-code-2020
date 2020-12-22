defmodule Day22 do
  #
  # Read and Parse
  #

  @spec input :: {deck_one :: [integer], deck_two :: [integer]}
  defp input do
    [deck_one, deck_two] =
      File.read!("22/input.txt")
      |> String.split("\n\n", trim: true)
      |> Enum.map(fn player ->
        String.split(player, "\n", trim: true)
        |> Enum.drop(1)
        |> Enum.map(&String.to_integer/1)
      end)

    {deck_one, deck_two}
  end

  #
  # Part One
  #

  @doc """
  With the standard version of Combat, we can recursively play rounds until we find a winner.
  """
  @spec part_one :: non_neg_integer
  def part_one do
    {deck_one, deck_two} = input()
    round(deck_one, deck_two)
  end

  # With player one having the higher card, we recurse to another round after giving player one
  # both cards in the correct order.
  #
  # Because of the base case, we don't need to check for a winning state here.
  #
  defp round([card_one | rest_one], [card_two | rest_two]) when card_one > card_two,
    do: round(rest_one ++ [card_one, card_two], rest_two)

  # Similar for player two having the higher card.
  defp round([card_one | rest_one], [card_two | rest_two]),
    do: round(rest_one, rest_two ++ [card_two, card_one])

  # With deck two empty, player one wins.
  defp round(deck_one, []), do: calculate_score(deck_one)

  # With deck one empty, player two wins.
  defp round([], deck_two), do: calculate_score(deck_two)

  # Enum.with_index/2 accepts a starting index as an optional second argument.
  defp calculate_score(deck) do
    deck
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {card, index} -> card * index end)
    |> Enum.sum()
  end

  #
  # Part Two
  #

  @doc """
  For part two, although the logic gets more complicated, we can use a lot of the same ideas. We
  will use a MapSet to keep track of history because looking up values is more efficient than a
  list. Our return values now need to include which player won as well as the score (since we
  don't know which the caller needs). As long as our recursive call is the return value (with no
  additional operations necessary after it returns) the compiler can perform tail-call optimization
  and help us avoid stack overflows. (There will be many rounds played, so this is important!)
  """
  @spec part_two :: non_neg_integer
  def part_two do
    {deck_one, deck_two} = input()
    {_winner, score} = recursive_round(deck_one, deck_two)

    score
  end

  # In a new game, by default, we start with empty history.
  defp recursive_round(deck_one, deck_two, history \\ MapSet.new())

  defp recursive_round(
         [card_one | rest_one] = deck_one,
         [card_two | rest_two] = deck_two,
         history
       ) do
    # Several branches need updated history, so we can calculate it here.
    new_history = MapSet.put(history, {deck_one, deck_two})

    cond do
      # First, check for a repeat state of the history.
      MapSet.member?(history, {deck_one, deck_two}) ->
        {:one, calculate_score(deck_one)}

      # Second, deal with the state in which one of the players doesn't have enough cards to play
      # a recursive game.
      #
      card_one > length(rest_one) or card_two > length(rest_two) ->
        if card_one > card_two do
          recursive_round(rest_one ++ [card_one, card_two], rest_two, new_history)
        else
          recursive_round(rest_one, rest_two ++ [card_two, card_one], new_history)
        end

      # Finally, deal with the state in which there are enough cards for a recursive game.
      true ->
        new_deck_one = Enum.slice(rest_one, 0..(card_one - 1))
        new_deck_two = Enum.slice(rest_two, 0..(card_two - 1))

        case recursive_round(new_deck_one, new_deck_two) do
          {:one, _score} ->
            recursive_round(rest_one ++ [card_one, card_two], rest_two, new_history)

          {:two, _score} ->
            recursive_round(rest_one, rest_two ++ [card_two, card_one], new_history)
        end
    end
  end

  # With deck two empty, player one wins.
  defp recursive_round(deck_one, [], _history), do: {:one, calculate_score(deck_one)}

  # With deck one empty, player two wins.
  defp recursive_round([], deck_two, _history), do: {:two, calculate_score(deck_two)}
end
