defmodule Day11 do
  @moduledoc """
  As an after-the-fact modification to this solution, I've implemented the `Array` class to assist
  in efficiency. Erlang/Elixir use linked lists for most things, but there is an `:array` module
  available in OTP. It provides O(1) lookups that would speed up this challenge, but the ergonomics
  are slightly awkward. `Array` provides an implementation of the `Enumerable` protocol so we can
  use `Enum` functions with these Erlang arrays, and it also has some nice helpers.

  It is because of this that `Enum.at/2`, for example, runs efficiently.
  """
  @type board :: Array.t(Array.t(String.t()))

  #
  # Read and Parse
  #

  @spec input :: board
  defp input do
    File.stream!("11/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.codepoints/1)
    |> Stream.map(&Array.from_list/1)
    |> Enum.to_list()
    |> Array.from_list(nil)
  end

  @offsets [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]

  #
  # Part One
  #

  @doc """
  For part one, we recursively call `play_round/2` with two arguments: the current state of the
  board and the previous state of the board. When the two states are the same, we are finished.
  Until then, we find the indices of each seat (empty or filled) and observe the adjacent seats.
  Based on the count of filled adjacent seats, we modify the state of the seat and continue.
  """
  @spec part_one :: integer
  def part_one do
    input()
    |> play_round()
  end

  # Each call of the function represents one round of changes, which all happen at once.
  @spec play_round(board, board) :: non_neg_integer
  defp play_round(board, previous \\ Array.new())

  # If the board has not changed, we are finished.
  defp play_round(board, board) do
    Enum.map(board, fn line -> Enum.count(line, &(&1 == "#")) end)
    |> Enum.sum()
  end

  # For each seat, observe adjacent seats and modify the state accordingly.
  defp play_round(board, _previous) do
    board
    |> Array.map_with_index(fn line, row ->
      Array.map_with_index(line, fn
        ".", _column ->
          "."

        "L", column ->
          case count_adjacent_seats(board, row, column) do
            0 -> "#"
            _ -> "L"
          end

        "#", column ->
          case count_adjacent_seats(board, row, column) do
            x when x >= 4 -> "L"
            _ -> "#"
          end
      end)
    end)
    |> play_round(board)
  end

  # When counting filled adjacent seats, we ignore out-of-bounds indices.
  defp count_adjacent_seats(board, row, column) do
    @offsets
    |> Enum.map(fn {r, c} -> {row + r, column + c} end)
    |> Enum.filter(fn {row, _column} -> row > -1 end)
    |> Enum.filter(fn {_row, column} -> column > -1 end)
    |> Enum.count(fn {row, column} ->
      row_array = Enum.at(board, row) || []
      point = Enum.at(row_array, column)

      point == "#"
    end)
  end

  #
  # Part Two
  #

  @doc """
  Part two looks much like part one, however the process of counting nearby occupied seats is now
  recursive. See `look/6` for more.
  """
  @spec part_two :: integer
  def part_two do
    input()
    |> play_advanced_round()
  end

  # Each call of the function represents one round of changes, which all happen at once.
  @spec play_advanced_round(board, board) :: non_neg_integer
  defp play_advanced_round(board, previous \\ Array.new())

  # If the board has not changed, we are finished.
  defp play_advanced_round(board, board) do
    Enum.map(board, fn line -> Enum.count(line, &(&1 == "#")) end)
    |> Enum.sum()
  end

  # For each seat, observe visible occupied seats and modify the state accordingly.
  defp play_advanced_round(board, _previous) do
    board
    |> Array.map_with_index(fn line, row ->
      Array.map_with_index(line, fn
        ".", _column ->
          "."

        "L", column ->
          case count_visible_seats(board, row, column) do
            0 -> "#"
            _ -> "L"
          end

        "#", column ->
          case count_visible_seats(board, row, column) do
            x when x >= 5 -> "L"
            _ -> "#"
          end
      end)
    end)
    |> play_advanced_round(board)
  end

  # When counting visible seats, we start a recursive search in each of the eight directions.
  @spec count_visible_seats(board, non_neg_integer, non_neg_integer) :: non_neg_integer
  defp count_visible_seats(board, row, column) do
    Enum.count(@offsets, fn {r, c} -> look(board, row, column, r, c) end)
  end

  # Given a direction (as described by the offsets), recursively look further outwards until we
  # either (1) find a seat, or (2) find the edge of the board.
  #
  @spec look(board, non_neg_integer, non_neg_integer, integer, integer, pos_integer) :: boolean
  defp look(board, row, column, offset_x, offset_y, multiple \\ 1)

  # `Enum.at/2` will attempt to wrap around backwards if we supply negative indices.
  defp look(_, row, _, _, offset_y, mult) when row + offset_y * mult < 0, do: false
  defp look(_, _, column, offset_x, _, mult) when column + offset_x * mult < 0, do: false

  defp look(board, row, column, offset_x, offset_y, multiple) do
    row_array = Enum.at(board, row + offset_y * multiple) || []
    point = Enum.at(row_array, column + offset_x * multiple)

    case point do
      "#" -> true
      "L" -> false
      nil -> false
      "." -> look(board, row, column, offset_x, offset_y, multiple + 1)
    end
  end
end
