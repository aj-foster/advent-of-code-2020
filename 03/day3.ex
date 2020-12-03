defmodule Day3 do
  #
  # Reading the File
  #

  # Stream the file line-by-line and trim trailing whitespace from each line.
  #
  @spec input :: Stream.t()
  defp input do
    File.stream!("03/input.txt")
    |> Stream.map(&String.trim/1)
  end

  #
  # Part One
  #

  @doc """
  This solution relies upon the fact that each line in the map is a continuously cycling collection
  of 31 characters. For line number X, the position in the map we visit is the remainder when you
  divide X * 3 by 31. To convince yourself, think through the first few columns you visit as you
  move down the map: 1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 3, 6, 9, ...

  By choosing a prime number as the dividend, the author ensured that we would visit every column
  as we progressed (regardless of how many moves right we make each time). That's thoughtful.

  With this formula in mind, we can quickly move through each line and calculate the left/right
  position we'll visit when we get there. After some adjusting for zero- vs one-based indices,
  we're finished.
  """
  @spec part_one :: non_neg_integer
  def part_one do
    input()
    |> Stream.with_index()
    |> Enum.count(fn {line, index} ->
      spot = rem(index * 3 + 1, 31)
      String.at(line, spot - 1) == "#"
    end)
  end

  #
  # Part Two
  #

  @doc """
  The formulaic way of finding the answer for part one really pays off in part two. Now that we're
  asked to take different paths, we need only to mess with the numbers involved in the formula
  each time.

  As a curveball, for the last one we're asked to move downward more than one line at a time. This
  was easiest done by removing the lines we'd skip and pretending that we're moving down by one
  on the remaining lines.
  """
  @spec part_two :: non_neg_integer
  def part_two do
    file =
      input()
      |> Stream.with_index()

    [
      # Right 1 Down 1
      file
      |> Enum.count(fn {line, index} ->
        spot = rem(index + 1, 31)
        String.at(line, spot - 1) == "#"
      end),

      # Right 3 Down 1
      part_one(),

      # Right 5 Down 1
      file
      |> Enum.count(fn {line, index} ->
        spot = rem(index * 5 + 1, 31)
        String.at(line, spot - 1) == "#"
      end),

      # Right 7 Down 1
      file
      |> Enum.count(fn {line, index} ->
        spot = rem(index * 7 + 1, 31)
        String.at(line, spot - 1) == "#"
      end),

      # Right 1 Down 2
      input()
      |> Stream.take_every(2)
      |> Stream.with_index()
      |> Enum.count(fn {line, index} ->
        spot = rem(index + 1, 31)
        String.at(line, spot - 1) == "#"
      end)
    ]
    |> Enum.reduce(&*/2)
  end
end
