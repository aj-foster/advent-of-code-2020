defmodule Day8 do
  #
  # Read and Parse
  #

  @spec input :: :array.array()
  defp input do
    File.stream!("08/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse/1)
    |> Enum.to_list()
    |> :array.from_list()
  end

  @spec parse(String.t()) :: {:acc | :jmp | :nop, integer}
  defp parse("acc +" <> rest), do: {:acc, String.to_integer(rest)}
  defp parse("acc -" <> rest), do: {:acc, -String.to_integer(rest)}
  defp parse("jmp +" <> rest), do: {:jmp, String.to_integer(rest)}
  defp parse("jmp -" <> rest), do: {:jmp, -String.to_integer(rest)}
  defp parse("nop +" <> rest), do: {:nop, String.to_integer(rest)}
  defp parse("nop -" <> rest), do: {:nop, -String.to_integer(rest)}

  #
  # Part One
  #

  @doc """
  For part one, we execute the program and observe the accumulator at the end. Execution occurs in
  `jump_around/3`. By using an Erlang array instead of a list, we can acheive O(1) lookup and
  updates. Unfortunately, functions in the `:array` module generally accept the array as the last
  argument instead of the first, so piping becomes slightly more difficult.
  """
  @spec part_one :: integer
  def part_one do
    input()
    |> jump_around()
    |> elem(1)
  end

  # While visiting instructions, replace them with `nil` to help discover any loops. Extendible
  # arrays will return `:undefined` for out-of-bounds indices, indicating the program has ended.
  #
  @spec jump_around(:array.array(), integer, non_neg_integer) ::
          {:end | :loop, integer}
  defp jump_around(instructions, acc \\ 0, index \\ 0) do
    case :array.get(index, instructions) do
      {:nop, _} ->
        instructions = :array.set(index, nil, instructions)
        index = index + 1
        jump_around(instructions, acc, index)

      {:acc, amount} ->
        instructions = :array.set(index, nil, instructions)
        acc = acc + amount
        index = index + 1
        jump_around(instructions, acc, index)

      {:jmp, amount} ->
        instructions = :array.set(index, nil, instructions)
        index = index + amount
        jump_around(instructions, acc, index)

      nil ->
        {:loop, acc}

      :undefined ->
        {:end, acc}
    end
  end

  #
  # Part Two
  #

  @doc """
  For part two, we use the friendly `Enum.reduce_while/3` function to fold the list of instructions
  and end early once we find the desired outcome. We'll continue to provide an Erlang array for
  the `jump_around/3` function.
  """
  @spec part_two :: integer
  def part_two do
    instructions = input()

    instructions
    |> :array.to_list()
    |> Enum.with_index()
    |> Enum.reduce_while(nil, fn
      {{:acc, _}, _index}, _ ->
        {:cont, nil}

      {{:nop, amount}, index}, _ ->
        :array.set(index, {:jmp, amount}, instructions)
        |> jump_around()
        |> case do
          {:loop, _} -> {:cont, nil}
          {:end, acc} -> {:halt, acc}
        end

      {{:jmp, amount}, index}, _ ->
        :array.set(index, {:nop, amount}, instructions)
        |> jump_around()
        |> case do
          {:loop, _} -> {:cont, nil}
          {:end, acc} -> {:halt, acc}
        end
    end)
  end
end
