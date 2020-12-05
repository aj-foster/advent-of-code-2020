defmodule Day5 do
  def part_one do
    File.stream!("05/input.txt")
    |> Stream.map(fn <<row::binary-size(7), column::binary-size(3), _::binary>> ->
      row =
        row
        |> String.replace("F", "0")
        |> String.replace("B", "1")
        |> String.to_integer(2)

      column =
        column
        |> String.replace("L", "0")
        |> String.replace("R", "1")
        |> String.to_integer(2)

      row * 8 + column
    end)
    |> Enum.max()
  end

  def part_two do
    taken =
      File.stream!("05/input.txt")
      |> Stream.map(fn <<row::binary-size(7), column::binary-size(3), _::binary>> ->
        row =
          row
          |> String.replace("F", "0")
          |> String.replace("B", "1")
          |> String.to_integer(2)

        column =
          column
          |> String.replace("L", "0")
          |> String.replace("R", "1")
          |> String.to_integer(2)

        {row, column}
      end)
      |> Enum.to_list()
      |> IO.inspect()

    for x <- 0..127, y <- 0..7 do
      case Enum.member?(taken, {x, y}) do
        true ->
          nil

        false ->
          IO.puts("Seat #{x}, #{y} is not taken")
      end
    end
  end
end
