defmodule Day1 do
  #
  # Reading the File
  #

  defp input do
    File.stream!("01/input.txt")
    |> Stream.filter(&(&1 != "\n"))
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
  end

  #
  # Part One
  #

  @doc """
  Because the list of numbers is not prohibitively long, we can get away with a brute force check
  of all pairs of numbers. This function doesn't return the answer we want, but rather prints out
  the answer (twice) as it finds it. Runtime is O(n^2).
  """
  @spec part_one_naive :: [nil]
  def part_one_naive do
    list = input()

    for x <- list, y <- list do
      if x + y == 2020 do
        IO.puts(x * y)
      end
    end
  end

  @doc """
  We can improve the runtime by sorting the list. This operation alone is O(n log n). Once we have
  a sorted list, we can use the following heuristic:

  ```
  1 2 3 5 6 7 8   target: 12
  ^           ^   Start by considering the numbers at the end of the list
    ^         ^   If the sum is too low, move "up" the list from the left
      ^       ^
        ^     ^
        ^   ^     If the sum is too high, move "down" the list from the right
        ^   ^     If we've found the pair, we're done.
  ```

  Lists in Elixir are linked lists, not arrays. Thus it's difficult to move backwards through a
  list efficiently. We can get around this by keeping a second copy of the list, reversed. The
  reversal is an O(n) operation.

  The movement through the list can be accomplished solely using guard clauses and pattern matching
  with recursive calls. This operation is O(n) since every step moves us through another element
  in the list (and previous elements never get revisited). This puts the final runtime at a nicer
  O(n log n).

  The lack of a base case for fold_in/3 demonstrates our assumption that the desired pair of numbers
  does exist in the list.
  """
  @spec part_one_folding :: number
  def part_one_folding do
    list = input() |> Enum.sort()
    reverse = Enum.reverse(list)

    fold_in(list, reverse, 2020)
  end

  defp fold_in([left | _rest], [right | _rest_reversed], target)
       when left + right == target,
       do: left * right

  defp fold_in([left | rest], [right | rest_reversed], target)
       when left + right > target,
       do: fold_in([left | rest], rest_reversed, target)

  defp fold_in([left | rest], [right | rest_reversed], target)
       when left + right < target,
       do: fold_in(rest, [right | rest_reversed], target)

  @doc """
  This method relies on the idea that if we can speed up the process of checking whether the list
  contains a given number, we can take any number X and look for (2020 - X) in the list. If it's
  there, we've found a valid pair of numbers.

  With a hash table that is pre-allocated to an appropriate size, we could quickly insert all of
  the numbers and then check for their complements using constant-time lookup. Unfortunately, the
  data structures available to Elixir don't achieve this ideal constant-time lookup. As a result
  our linear search through the list and the repeated set membership lookups gives us the same
  O(n log n) runtime as before.
  """
  @spec part_one_hashed :: number
  def part_one_hashed do
    list = input()
    set = Enum.reduce(list, MapSet.new(), &MapSet.put(&2, &1))
    number = Enum.find(list, &MapSet.member?(set, 2020 - &1))

    number * (2020 - number)
  end

  #
  # Part Two
  #

  @doc """
  Because the list of numbers is not prohibitively long, we can get away with a brute force check
  of all triplets of numbers. This function doesn't return the answer we want, but rather prints out
  the answer (6 times) as it finds it. Runtime is O(n^3).
  """
  @spec part_two_naive :: [nil]
  def part_two_naive do
    list = input()

    for x <- list, y <- list, z <- list do
      if x + y + z == 2020 do
        IO.puts(x * y * z)
      end
    end
  end
end
