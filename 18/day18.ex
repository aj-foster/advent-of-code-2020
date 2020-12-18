defmodule Day18 do
  #
  # Read and Parse
  #

  defp input do
    File.stream!("18/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse/1)
  end

  defp parse(input, result \\ [])

  defp parse(<<" ", rest::binary>>, result), do: parse(rest, result)
  defp parse(<<"(", rest::binary>>, result), do: parse(rest, [:< | result])
  defp parse(<<")", rest::binary>>, result), do: parse(rest, [:> | result])
  defp parse(<<"+", rest::binary>>, result), do: parse(rest, [:+ | result])
  defp parse(<<"*", rest::binary>>, result), do: parse(rest, [:* | result])
  defp parse("", result), do: Enum.reverse(result)

  defp parse(<<number::binary-1, rest::binary>>, result),
    do: parse(rest, [String.to_integer(number) | result])

  #
  # Part One
  #

  @spec part_one :: number
  def part_one do
    input()
    |> Stream.map(&evaluate/1)
    |> Enum.sum()
  end

  defp evaluate(input, result \\ 0, operation \\ nil)
  defp evaluate([], result, nil), do: result

  defp evaluate([:+ | rest], result, _op), do: evaluate(rest, result, &Kernel.+/2)
  defp evaluate([:* | rest], result, _op), do: evaluate(rest, result, &Kernel.*/2)
  defp evaluate([num | rest], 0, nil) when is_number(num), do: evaluate(rest, num, nil)

  defp evaluate([num | rest], result, op) when is_number(num) and not is_nil(op) do
    evaluate(rest, op.(result, num), nil)
  end

  defp evaluate([:< | rest], result, operation) do
    subset =
      Enum.reduce_while(rest, {[], 1}, fn
        :<, {subset, level} -> {:cont, {[:< | subset], level + 1}}
        :>, {subset, 1} -> {:halt, subset}
        :>, {subset, level} -> {:cont, {[:> | subset], level - 1}}
        x, {subset, level} -> {:cont, {[x | subset], level}}
      end)
      |> Enum.reverse()

    value = evaluate(subset, 0, nil)
    rest = Enum.drop(rest, length(subset) + 1)

    evaluate([value | rest], result, operation)
  end

  #
  # Part Two
  #

  @spec part_two :: number
  def part_two do
    input()
    |> Stream.map(&evaluate2/1)
    |> Enum.sum()
  end

  defp evaluate2(input, result \\ 0, operation \\ nil)
  defp evaluate2([], result, nil), do: result

  defp evaluate2([:+ | rest], result, _op), do: evaluate2(rest, result, :+)
  defp evaluate2([:* | rest], result, _op), do: evaluate2(rest, result, :*)
  defp evaluate2([num | rest], 0, nil) when is_number(num), do: evaluate2(rest, num, nil)

  defp evaluate2([num | rest], result, :*) when is_number(num) do
    result * evaluate2(rest, num, nil)
  end

  defp evaluate2([num | rest], result, :+) when is_number(num) do
    evaluate2(rest, result + num, nil)
  end

  defp evaluate2([:< | rest], result, operation) do
    subset =
      Enum.reduce_while(rest, {[], 1}, fn
        :<, {subset, level} -> {:cont, {[:< | subset], level + 1}}
        :>, {subset, 1} -> {:halt, subset}
        :>, {subset, level} -> {:cont, {[:> | subset], level - 1}}
        x, {subset, level} -> {:cont, {[x | subset], level}}
      end)
      |> Enum.reverse()

    value = evaluate2(subset, 0, nil)
    rest = Enum.drop(rest, length(subset) + 1)

    evaluate2([value | rest], result, operation)
  end
end
