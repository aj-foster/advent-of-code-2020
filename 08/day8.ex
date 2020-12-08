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

  def part_one do
    input()
    |> Enum.to_list()
    |> jumper_hound(0)
  end

  defp jumper_hound(instructions, acc, index \\ 0) do
    case Enum.at(instructions, index) do
      {:nop, _} ->
        instructions = List.update_at(instructions, index, fn _ -> nil end)
        index = index + 1
        jumper_hound(instructions, acc, index)

      {:acc, amount} ->
        instructions = List.update_at(instructions, index, fn _ -> nil end)
        acc = acc + amount
        index = index + 1
        jumper_hound(instructions, acc, index)

      {:jmp, amount} ->
        instructions = List.update_at(instructions, index, fn _ -> nil end)
        index = index + amount
        jumper_hound(instructions, acc, index)

      nil ->
        acc
    end
  end

  #
  # Part Two
  #

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
        |> List.update_at(index, fn _ -> {:jmp, amount} end)
        |> jumper_hound2()
        |> case do
          false -> {:cont, nil}
          acc when is_number(acc) -> {:halt, acc}
        end

      {{:jmp, amount}, index}, _ ->
        instructions
        |> List.update_at(index, fn _ -> {:nop, amount} end)
        |> jumper_hound2()
        |> case do
          false -> {:cont, nil}
          acc when is_number(acc) -> {:halt, acc}
        end
    end)
  end

  defp jumper_hound2(instructions, acc \\ 0, index \\ 0) do
    case Enum.at(instructions, index, :end) do
      {:nop, _} ->
        instructions = List.update_at(instructions, index, fn _ -> nil end)
        index = index + 1
        jumper_hound2(instructions, acc, index)

      {:acc, amount} ->
        instructions = List.update_at(instructions, index, fn _ -> nil end)
        acc = acc + amount
        index = index + 1
        jumper_hound2(instructions, acc, index)

      {:jmp, amount} ->
        instructions = List.update_at(instructions, index, fn _ -> nil end)
        index = index + amount
        jumper_hound2(instructions, acc, index)

      nil ->
        false

      :end ->
        acc
    end
  end
end
