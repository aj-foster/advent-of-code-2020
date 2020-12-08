defmodule Day8 do
  #
  # Read and Parse
  #

  defp input do
    File.stream!("08/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse/1)
  end

  defp parse("acc +" <> rest), do: {:acc, String.to_integer(rest)}
  defp parse("acc -" <> rest), do: {:acc, -String.to_integer(rest)}
  defp parse("jmp +" <> rest), do: {:jmp, String.to_integer(rest)}
  defp parse("jmp -" <> rest), do: {:jmp, -String.to_integer(rest)}
  defp parse("nop +" <> rest), do: {:nop, String.to_integer(rest)}
  defp parse("nop -" <> rest), do: {:nop, -String.to_integer(rest)}

  #
  # Part One
  #

  @spec part_one :: number
  def part_one do
    input()
    |> Enum.to_list()
    |> jump_around()
    |> elem(1)
  end

  defp jump_around(instructions, acc \\ 0, index \\ 0) do
    case Enum.at(instructions, index, :end) do
      {:nop, _} ->
        instructions = List.replace_at(instructions, index, nil)
        index = index + 1
        jump_around(instructions, acc, index)

      {:acc, amount} ->
        instructions = List.replace_at(instructions, index, nil)
        acc = acc + amount
        index = index + 1
        jump_around(instructions, acc, index)

      {:jmp, amount} ->
        instructions = List.replace_at(instructions, index, nil)
        index = index + amount
        jump_around(instructions, acc, index)

      nil ->
        {:loop, acc}

      :end ->
        {:end, acc}
    end
  end

  #
  # Part Two
  #

  @spec part_two :: number
  def part_two do
    instructions =
      input()
      |> Enum.to_list()

    instructions
    |> Enum.with_index()
    |> Enum.reduce_while(nil, fn
      {{:acc, _}, _index}, _ ->
        {:cont, nil}

      {{:nop, amount}, index}, _ ->
        instructions
        |> List.replace_at(index, {:jmp, amount})
        |> jump_around()
        |> case do
          {:loop, _} -> {:cont, nil}
          {:end, acc} -> {:halt, acc}
        end

      {{:jmp, amount}, index}, _ ->
        instructions
        |> List.replace_at(index, {:nop, amount})
        |> jump_around()
        |> case do
          {:loop, _} -> {:cont, nil}
          {:end, acc} -> {:halt, acc}
        end
    end)
  end
end
