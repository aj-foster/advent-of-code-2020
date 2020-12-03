defmodule Day3 do
  #
  # Reading the File
  #

  defp input do
    File.read!("03/input.txt")
    |> String.split("\n", trim: true)
  end

  #
  # Part One
  #

  def part_one do
    input()
    |> Enum.with_index()
    |> Enum.count(fn {line, index} ->
      spot = rem(index * 3 + 1, 31)
      String.at(line, spot - 1) == "#"
    end)
  end

  #
  # Part Two
  #

  def part_two do
    file =
      input()
      |> Enum.with_index()

    a =
      file
      |> Enum.count(fn {line, index} ->
        spot = rem(index + 1, 31)
        String.at(line, spot - 1) == "#"
      end)
      |> IO.inspect(label: "Right 1 Down 1")

    b =
      file
      |> Enum.count(fn {line, index} ->
        spot = rem(index * 3 + 1, 31)
        String.at(line, spot - 1) == "#"
      end)
      |> IO.inspect(label: "Right 3 Down 1")

    c =
      file
      |> Enum.count(fn {line, index} ->
        spot = rem(index * 5 + 1, 31)
        String.at(line, spot - 1) == "#"
      end)
      |> IO.inspect(label: "Right 5 Down 1")

    d =
      file
      |> Enum.count(fn {line, index} ->
        spot = rem(index * 7 + 1, 31)
        String.at(line, spot - 1) == "#"
      end)
      |> IO.inspect(label: "Right 7 Down 1")

    e =
      input()
      |> Enum.take_every(2)
      |> Enum.with_index()
      |> Enum.count(fn {line, index} ->
        spot = rem(index + 1, 31)
        String.at(line, spot - 1) == "#"
      end)
      |> IO.inspect(label: "Right 1 Down 2")

    a * b * c * d * e
  end
end
