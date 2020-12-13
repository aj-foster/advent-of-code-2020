defmodule Day13 do
  def part_one do
    [time, schedule] =
      File.read!("13/input.txt")
      |> String.split("\n", trim: true)

    time = String.to_integer(time)

    buses =
      String.split(schedule, ",")
      |> Enum.reject(&(&1 == "x"))
      |> Enum.map(&String.to_integer/1)

    buses
    |> Enum.map(fn x -> {x, time + x - rem(time, x)} end)
    |> Enum.min_by(fn {_x, time} -> time end)
  end

  def part_two do
    rules =
      File.read!("13/input.txt")
      |> String.split("\n", trim: true)
      |> List.last()
      |> String.split(",")
      |> Enum.map(fn
        "x" -> nil
        num -> String.to_integer(num)
      end)
      |> Enum.with_index()
      |> Enum.reject(fn {x, _} -> is_nil(x) end)
      |> Enum.sort_by(fn {x, _} -> x end, :desc)

    0..15
    |> Enum.map(fn x ->
      Task.async(fn ->
        stuff_parallel_improved(rules, x * elem(List.first(rules), 0), elem(List.first(rules), 1))
      end)
    end)
    |> Enum.map(fn job -> Task.await(job, :infinity) end)

    # stuff(rules, 0)
  end

  defp stuff(rules, attempt) do
    Enum.all?(rules, fn
      {nil, _} -> true
      {x, delta} -> rem(attempt + delta, x) == 0
    end)
    |> case do
      true -> attempt
      false -> stuff(rules, attempt + elem(List.first(rules), 0))
    end
  end

  defp stuff_parallel(rules, attempt) do
    Enum.all?(rules, fn
      {nil, _} -> true
      {x, delta} -> rem(attempt + delta, x) == 0
    end)
    |> case do
      true ->
        IO.puts("The answer is #{attempt}")
        attempt

      false ->
        stuff_parallel(rules, attempt + 16 * elem(List.first(rules), 0))
    end
  end

  defp stuff_parallel_improved(rules, attempt, offset) do
    Enum.all?(rules, fn
      {nil, _} -> true
      {x, delta} -> rem(attempt + delta - offset, x) == 0
    end)
    |> case do
      true ->
        IO.puts("The answer is #{attempt}")
        attempt

      false ->
        stuff_parallel_improved(rules, attempt + 16 * elem(List.first(rules), 0), offset)
    end
  end

  def part_two_different do
    rules =
      File.read!("13/input.txt")
      |> String.split("\n", trim: true)
      |> List.last()
      |> String.split(",")
      |> Enum.map(fn
        "x" -> nil
        num -> String.to_integer(num)
      end)
      |> Enum.with_index()
      |> Enum.reject(fn {x, _} -> is_nil(x) end)

    rules
    |> Enum.reduce(fn {x, x_offset}, {y, y_offset} ->
      IO.puts("Now reducing... #{x}")

      mult =
        0..(x - 1)
        |> Enum.find(fn mult ->
          rem(y * mult - y_offset + x_offset, x) == 0
        end)

      {x * y, y_offset - mult * y}
    end)
  end
end
