defmodule Day5 do
  import Bitwise

  #
  # Read and Parse
  #

  defp input do
    File.stream!("05/input.txt")
    |> Stream.map(&parse_seat/1)
  end

  defp parse_seat(<<row::binary-size(7), column::binary-size(3), _::binary>>) do
    {
      parse_row(row),
      parse_column(column)
    }
  end

  # We can treat F/B characters like binary digits. We start from 0, and shift the number right
  # every time we read a character. If the character is a B, we'll add one to make the next binary
  # digit a 1.
  #
  # FBF
  #          0
  # ^       00
  #  ^     001
  #   ^   0010
  #
  defp parse_row(row_string, row_binary \\ 0)
  defp parse_row("F" <> rest, row), do: parse_row(rest, row <<< 1)
  defp parse_row("B" <> rest, row), do: parse_row(rest, (row <<< 1) + 1)
  defp parse_row("", row), do: row

  # Similar to rows, we can treat L/R as 0/1, respectively.
  #
  defp parse_column(column_string, column_binary \\ 0)
  defp parse_column("L" <> rest, column), do: parse_column(rest, column <<< 1)
  defp parse_column("R" <> rest, column), do: parse_column(rest, (column <<< 1) + 1)
  defp parse_column("", column), do: column

  #
  # Part One
  #

  @doc """
  For part one, we can convert locations to seat IDs and pick the largest ID.
  """
  @spec part_one :: non_neg_integer
  def part_one do
    input()
    |> Stream.map(&location_to_id/1)
    |> Enum.max()
  end

  defp location_to_id({row, column}), do: row * 8 + column

  #
  # Part Two
  #

  @doc """
  For part two, we can sort the list of seat IDs and look for a gap in the list.
  """
  @spec part_two :: non_neg_integer
  def part_two do
    input()
    |> Stream.map(&location_to_id/1)
    |> Enum.sort(:asc)
    |> find_gap()
  end

  defp find_gap([x, y | _rest]) when y == x + 2, do: x + 1
  defp find_gap([_x, y | rest]), do: find_gap([y | rest])
end
