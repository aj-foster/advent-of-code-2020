defmodule Day10 do
  def part_one do
    File.read!("10/input.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort()
    |> Enum.reduce({0, 0, 0}, fn x, {prev, ones, threes} ->
      case x - prev do
        1 ->
          {x, ones + 1, threes}

        3 ->
          {x, ones, threes + 1}

        _ ->
          {x, ones, threes}
      end
    end)
  end

  def part_two do
    {acc, final_group, _} =
      File.read!("10/input.txt")
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.sort()
      |> Enum.reduce({[], [0], 0}, fn x, {acc, group, prev} ->
        case x - prev do
          3 ->
            {[Enum.reverse(group) | acc], [x], x}

          _ ->
            {acc, [x | group], x}
        end
      end)

    # |> IO.inspect()

    Enum.reverse([Enum.reverse(final_group) | acc])
    |> Enum.map(&count/1)
    |> Enum.reduce(&*/2)

    # count([0 | adapters])
  end

  # defp count([a, b, c | rest]) when c - a > 3 do
  #   count([b, c | rest])
  # end

  # defp count([a, _b, _c, d | rest]) when d - a == 3 do
  #   count(rest) + count([c, d | rest])
  # end

  # defp count([a, b, c | rest]) when c - a <= 3 do
  #   count([c | rest]) * 2
  # end

  # defp count([_a, _b]), do: 1
  # defp count([]), do: 1

  defp count([a, b, c | rest]) when c - a <= 3, do: count([a, c | rest]) + count([b, c | rest])
  defp count([_a, b, c | rest]), do: count([b, c | rest])
  defp count([_a, _b]), do: 1
  defp count([_a]), do: 1
  defp count([]), do: 0

  # defp count2([a, b | rest]) when b - a == 3, do: count(rest)
  # defp count2([a, _b, c | rest]) when c - a == 3, do: count(rest) * 2
  # defp count2([a, _b, c | rest]) when c - a = 3, do: count(rest) * 2

  defp count3([_]), do: 1
  defp count3([_a, _b]), do: 1

  # 1 3 5
  defp count3([a, _b, c]) when c == a + 4, do: 1
  # 1 2 3
  # 1 2 4
  # 1 3 4
  defp count3([_a, _b, _c]), do: 2

  # 1 2 3 4
  defp count3([a, _b, _c, d]) when d == a + 3, do: 4
  # 1 2 3 5
  # 1 3 4 5
  defp count3([a, _b, _c, d]) when d == a + 4, do: 3
  # 1 2 3 6
  # 1 3 5 6
  defp count3([a, _b, _c, d]) when d == a + 5, do: 2
  # 1 3 5 7
  defp count3([a, _b, _c, d]) when d == a + 6, do: 1

  # 1 2 3 4 5
  defp count3([a, _b, _c, _d, e]) when e == a + 4, do: 7

  # 5

  # 1 2 3 4 6
  defp count3([a, _b, _c, d, e]) when d == a + 3 and e == a + 5, do: 6
  # 1 2 3 5 6
  defp count3([a, _b, c, d, e]) when c == a + 2 and d == a + 4 and e == a + 5, do: 5
  # 1 2 4 5 6
  defp count3([a, b, _c, d, e]) when b == a + 1 and d == a + 4 and e == a + 5, do: 5
  # 1 3 4 5 6
  defp count3([a, b, _c, d, e]) when b == a + 2 and d == a + 4 and e == a + 5, do: 6

  # 6

  # 1 2 3 5 7
  defp count3([a, b, c, d, e]) when b == a + 1 and c == a + 2 and d == a + 4 and e == a + 6, do: 3
  # 1 3 5 6 7
  defp count3([a, b, c, d, e]) when b == a + 2 and c == a + 4 and d == a + 5 and e == a + 6, do: 3

  # 1 2 3 4 7
  defp count3([a, b, c, d, e]) when b == a + 1 and c == a + 2 and d == a + 3 and e == a + 6, do: 4
  # 1 4 5 6 7
  defp count3([a, b, c, d, e]) when b == a + 3 and c == a + 4 and d == a + 5 and e == a + 6, do: 4

  # 1 2 4 5 7
  defp count3([a, b, c, d, e]) when b == a + 1 and c == a + 3 and d == a + 4 and e == a + 6, do: 5
  # 1 3 4 6 7
  defp count3([a, b, c, d, e]) when b == a + 2 and c == a + 3 and d == a + 5 and e == a + 6, do: 5

  # 1 3 4 5 7
  defp count3([a, b, c, d, e]) when b == a + 2 and c == a + 3 and d == a + 5 and e == a + 6, do: 5

  # 7

  # 1 2 4 6 8
  defp count3([a, b, c, d, e]) when b == a + 1 and c == a + 3 and d == a + 5 and e == a + 7, do: 2
  # 1 3 5 7 8
  defp count3([a, b, c, d, e]) when b == a + 2 and c == a + 4 and d == a + 6 and e == a + 7, do: 2

  # 1 3 4 6 8
  defp count3([a, b, c, d, e]) when b == a + 2 and c == a + 3 and d == a + 5 and e == a + 7, do: 3
  # 1 3 5 6 8
  defp count3([a, b, c, d, e]) when b == a + 2 and c == a + 4 and d == a + 5 and e == a + 7, do: 3

  # 8

  # 1 3 5 7 9
  defp count3([a, _b, _c, _d, e]) when e == a + 8, do: 1
end

# 1 2 3 4 7
# 1 3 4 7
# 1 2 4 7
# 1 4 7

# 1 2 3 5 7
# 1 2 5 7
# 1 3 5 7

# 1 2 4 5 7
# 1 2 5 7
# 1 2 4 7
# 1 4 5 7
# 1 4 7

# 1 3 4 5 7
# 1 4 5 7
# 1 3 4 7
# 1 3 5 7
# 1 4 7

# 1 3 5 6 7
# 1 3 5 7
# 1 3 6 7

# 1 2 3 4 5
# 1 3 4 5
# 1 2 4 5
# 1 2 3 5
# 1 4 5
# 1 3 5
# 1 2 5

# 1 2 3 4 6
# 1 3 4 6
# 1 2 4 6
# 1 2 3 6
# 1 4 6
# 1 3 6

# 1 2 3 5 6
# 1 3 5 6
# 1 2 5 6
# 1 2 3 6
# 1 3 6

# 1 2 4 5 6
# 1 4 5 6
# 1 2 5 6
# 1 4 6

# 1 3 4 5 6
# 1 4 5 6
# 1 3 5 6
# 1 3 4 6
# 1 4 6
# 1 3 6

#
#
#
#
#

# 1 3 4 5 6
# 1 4 5 6
# 1 3 5 6
# 1 3 6

# 1 2 3 4   5 6 7 8
# 1 3 4     5 6 7 8
# 1 2 4     5 6 7 8
# 1 4       5 6 7 8

# 1 2 3   5 6 7 8
# 1 3     5 6 7 8
# 1 2     5 6 7 8

# 1 2 3 4   5 6 7 8
# 1 3 4     5 6 7 8
# 1 2 4     5 6 7 8
# 1 4       5 6 7 8

# 1 2 3 4 5 6 7 8

# 1 2 4 5 6 7 8
# 1 3 4 5 6 7 8

# 1 2 5 6 7 8
# 1 3 5 6 7 8
# 1 4 5 6 7 8

# 1 4 5 7 8
# 1 4 6 7 8

# 1 4 5 8
# 1 4 6 8
# 1 4 7 8
