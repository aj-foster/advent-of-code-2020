defmodule Day11 do
  #
  # Read and Parse
  #

  @spec input :: [String.t()]
  defp input do
    File.stream!("11/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.codepoints/1)
    |> Enum.to_list()
  end

  @offsets [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]

  #
  # Part One
  #

  @spec part_one :: integer
  def part_one do
    input()
    |> play_round()
  end

  defp play_round(board, previous \\ [])

  # If the board has not changed, we are finished.
  defp play_round(board, board) do
    Enum.map(board, fn line -> Enum.count(line, &(&1 == "#")) end)
    |> Enum.sum()
  end

  defp play_round(board, _previous) do
    indexed = Enum.with_index(Enum.map(board, &Enum.with_index/1))

    new_board =
      indexed
      |> Enum.map(fn {line, row} ->
        Enum.map(line, fn
          {".", _column} ->
            "."

          {"L", column} ->
            case count_adjacent_seats(board, row, column) do
              0 -> "#"
              _ -> "L"
            end

          {"#", column} ->
            case count_adjacent_seats(board, row, column) do
              x when x >= 4 -> "L"
              _ -> "#"
            end
        end)
      end)

    play_round(new_board, board)
  end

  defp count_adjacent_seats(board, row, column) do
    @offsets
    |> Enum.map(fn {r, c} -> {row + r, column + c} end)
    |> Enum.filter(fn {row, _column} -> row > -1 end)
    |> Enum.filter(fn {_row, column} -> column > -1 end)
    |> Enum.count(fn {row, column} ->
      row = Enum.at(board, row) || []
      point = Enum.at(row, column)

      point == "#"
    end)
  end

  #
  # Part Two
  #

  @spec part_two :: integer
  def part_two do
    input()
    |> play_advanced_round()
  end

  defp play_advanced_round(board, previous \\ [])

  defp play_advanced_round(board, board) do
    Enum.map(board, fn line -> Enum.count(line, &(&1 == "#")) end)
    |> Enum.sum()
  end

  defp play_advanced_round(board, _previous) do
    indexed = Enum.with_index(Enum.map(board, &Enum.with_index/1))

    new_board =
      indexed
      |> Enum.map(fn {line, row} ->
        Enum.map(line, fn
          {".", _column} ->
            "."

          {"L", column} ->
            case count_visible_seats(board, row, column) do
              0 -> "#"
              _ -> "L"
            end

          {"#", column} ->
            case count_visible_seats(board, row, column) do
              x when x >= 5 -> "L"
              _ -> "#"
            end
        end)
      end)

    play_advanced_round(new_board, board)
  end

  defp count_visible_seats(board, row, column) do
    Enum.count(@offsets, fn {r, c} -> look(board, row, column, r, c) end)
  end

  defp look(board, row, column, offset_x, offset_y, multiple \\ 1)

  defp look(_, row, _, _, offset_y, mult) when row + offset_y * mult < 0, do: false
  defp look(_, _, column, offset_x, _, mult) when column + offset_x * mult < 0, do: false

  defp look(board, row, column, offset_x, offset_y, multiple) do
    case Enum.at(Enum.at(board, row + offset_y * multiple) || [], column + offset_x * multiple) do
      "#" -> true
      "L" -> false
      nil -> false
      "." -> look(board, row, column, offset_x, offset_y, multiple + 1)
    end
  end
end
