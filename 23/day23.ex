defmodule Day23 do
  #
  # Read and Parse
  #

  @spec input :: Enumerable.t()
  defp input do
    File.stream!("23/input.txt", [], 1)
    |> Stream.map(&String.to_integer/1)
  end

  #
  # Part One
  #

  @doc """
  In part one, we implement the cups game using lists. During each round, we modify the list and
  shift the elements such that the current cup is always the first element. Recall that because
  lists are linked lists in Erlang, many of the list operations take O(n) time.
  """
  @spec part_one :: binary
  def part_one do
    input()
    |> Enum.to_list()
    |> play_round()
  end

  # Each call of this function represents one round of play. The `move` argument increments
  # accordingly.
  #
  @spec play_round([non_neg_integer], integer) :: binary
  defp play_round(cups, move \\ 0)

  # After the 100th round (remember, we started from zero), we cycle the list and take the eight
  # values after the number 1.
  #
  defp play_round(cups, 100),
    do:
      Stream.cycle(cups)
      |> Stream.drop_while(&(&1 != 1))
      |> Stream.drop(1)
      |> Enum.take(8)
      |> Enum.join()

  # During a normal round of play, we maintain the "current" cup at the front of the list and move
  # the following three cups.
  #
  defp play_round([current, one, two, three | rest], move) do
    picked = [one, two, three]
    destination = get_destination(current, picked, 9)
    index = Enum.find_index(rest, &(&1 == destination))

    cups =
      (List.insert_at(rest, index + 1, picked) ++ [current])
      |> List.flatten()

    play_round(cups, move + 1)
  end

  # There are four possibilities for the destination cup, depending how many candidate destination
  # cups are among the picked ones.
  #
  @spec get_destination(non_neg_integer, [non_neg_integer], non_neg_integer) :: non_neg_integer
  defp get_destination(current, picked, modulo) do
    cond do
      mod(current - 1, modulo) not in picked -> mod(current - 1, modulo)
      mod(current - 2, modulo) not in picked -> mod(current - 2, modulo)
      mod(current - 3, modulo) not in picked -> mod(current - 3, modulo)
      true -> mod(current - 4, modulo)
    end
  end

  # This modified modulo / remainder operator is specifically made for keeping a value within the
  # [1, n] range, and dealing with values that hit 0 or lower.
  #
  @spec mod(integer, non_neg_integer) :: non_neg_integer
  defp mod(input, modulo) when input <= 0, do: input + modulo
  defp mod(input, _modulo), do: input

  #
  # Part Two
  #

  @doc """
  In part two, we have too large of a list — and too many rounds — to efficiently play rounds using
  the original linked list structure. Because the game always moves cups to the right of something
  (for example, the picked cups move to the right, or clockwise, of the destination) it seems we
  only need to keep track of the relationship between a cup and its right-side neighbor.

  We build a map with the cup labels as keys, and the right-side / clockwise neighbor as values.
  Finding and moving cups requires map lookups and updates, which are at-most O(log n) operations.
  """
  @spec part_two :: integer
  def part_two do
    input = input()
    [first] = Enum.take(input, 1)

    input
    |> Stream.concat(10..1_000_000)
    |> Enum.to_list()
    |> build_map()
    |> play_large_round(first)
  end

  # The first item in the cycle is preceded by cup 1,000,000.
  @spec build_map([non_neg_integer], map, non_neg_integer) :: map
  defp build_map(list, map \\ %{}, previous \\ 1_000_000)

  defp build_map([head | tail], map, previous) do
    build_map(tail, Map.put(map, previous, head), head)
  end

  defp build_map([], map, _previous), do: map

  # Playing a round now involves map lookups and updates, but we can continue to use the same
  # destination calculation as before.
  #
  @spec play_large_round(map, non_neg_integer, integer) :: integer
  defp play_large_round(cups, current, move \\ 0)

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
    post_picked = Map.fetch!(cups, three)

    destination = get_destination(current, picked, 1_000_000)
    post_destination = Map.fetch!(cups, destination)

    cups
    |> Map.put(destination, one)
    |> Map.put(three, post_destination)
    |> Map.put(current, post_picked)
    |> play_large_round(post_picked, move + 1)
  end
end
