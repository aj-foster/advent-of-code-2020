defmodule Day11 do
  #
  # Read and Parse
  #

  defp input do
    File.stream!("11/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.codepoints/1)
  end

  #
  # Part One
  #

  @offsets [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]

  def part_one do
    input()
    |> Enum.to_list()
    |> stuff()
  end

  defp stuff(board, previous \\ [])

  defp stuff(board, board) do
    Enum.map(board, fn line -> Enum.count(line, &(&1 == "#")) end)
    |> Enum.reduce(&+/2)
  end

  defp stuff(board, _previous) do
    indexed = Enum.with_index(Enum.map(board, &Enum.with_index/1))

    new_board =
      indexed
      |> Enum.map(fn {line, row} ->
        Enum.map(line, fn
          {".", _column} ->
            "."

          {"L", column} ->
            [
              {row - 1, column - 1},
              {row, column - 1},
              {row + 1, column - 1},
              {row - 1, column},
              {row + 1, column},
              {row - 1, column + 1},
              {row, column + 1},
              {row + 1, column + 1}
            ]
            |> Enum.count(fn {r, c} ->
              r > -1 and c > -1 and Enum.at(Enum.at(board, r) || [], c) == "#"
            end)
            |> case do
              0 -> "#"
              _ -> "L"
            end

          {"#", column} ->
            [
              {row - 1, column - 1},
              {row, column - 1},
              {row + 1, column - 1},
              {row - 1, column},
              {row + 1, column},
              {row - 1, column + 1},
              {row, column + 1},
              {row + 1, column + 1}
            ]
            |> Enum.count(fn {r, c} ->
              r > -1 and c > -1 and Enum.at(Enum.at(board, r) || [], c) == "#"
            end)
            |> case do
              x when x >= 4 -> "L"
              _ -> "#"
            end
        end)
      end)

    stuff(new_board, board)
  end

  #
  # Part Two
  #

  def part_two do
    input()
    |> Enum.to_list()
    |> stuff2()
  end

  defp stuff2(board, previous \\ [])

  defp stuff2(board, board) do
    Enum.map(board, fn line -> Enum.count(line, &(&1 == "#")) end)
    |> Enum.reduce(&+/2)
  end

  defp stuff2(board, _previous) do
    indexed = Enum.with_index(Enum.map(board, &Enum.with_index/1))

    new_board =
      indexed
      |> Enum.map(fn {line, row} ->
        Enum.map(line, fn
          {".", _column} ->
            "."

          {"L", column} ->
            Enum.count(@offsets, fn {r, c} -> look(board, row, column, r, c) end)
            |> case do
              0 -> "#"
              _ -> "L"
            end

          {"#", column} ->
            Enum.count(@offsets, fn {r, c} -> look(board, row, column, r, c) end)
            |> case do
              x when x >= 5 -> "L"
              _ -> "#"
            end
        end)
      end)

    stuff2(new_board, board)
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
