defmodule Day13 do
  #
  # Read and Parse
  #

  defp input do
    File.read!("13/input.txt")
    |> String.split("\n", trim: true)
  end

  defp parse_bus_ids(line) do
    String.split(line, ",")
    |> Enum.map(fn
      "x" -> nil
      num -> String.to_integer(num)
    end)
    |> Enum.with_index()
    |> Enum.reject(fn {x, _} -> is_nil(x) end)
  end

  #
  # Part One
  #

  @doc """
  The critical realization for this part is that the time it takes for a bus to appear after the
  given point in time is related to the remainder when you divide the time by the bus ID (which is
  also the cycle time of the bus). When the given time occurs, the bus has (total length of the
  cycle - remainder from the division) time left before it appears again. Minimizing this number
  finds the closest bus.
  """
  @spec part_one :: any
  def part_one do
    [time, schedule] = input()
    time = String.to_integer(time)

    String.split(schedule, ",")
    |> Enum.reject(&(&1 == "x"))
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(fn bus -> {bus, bus - rem(time, bus)} end)
    |> Enum.min_by(fn {_bus, time_delta} -> time_delta end)
    |> (fn {bus, time_delta} -> bus * time_delta end).()
  end

  #
  # Part Two
  #

  @number_of_cores 16

  @doc """
  In this version, we attempt to find an answer via brute force while optimizing just a little. We
  know that the answer has the form T = X*n - A where n is some integer, X is a bus ID, and A is
  the timing offset. We can start guessing every value of n for any of the bus ID / offset
  combinations. We might as well choose X to be the biggest bus ID available, our guesses for T
  reach the real answer as fast as possible. We also might as well split the checks across all of
  the computer's cores.

  This never finished for me.
  """
  @spec part_two_naive :: [number]
  def part_two_naive do
    rules =
      input()
      |> List.last()
      |> parse_bus_ids()
      |> Enum.sort_by(fn {x, _} -> x end, :desc)

    # Use the first rule (sorted descending by bus ID) as the jump to add each time.
    [{jump, offset} | _] = rules

    # We'll start each process at a different attempt, and then make them jump past each other.
    0..(@number_of_cores - 1)
    |> Enum.map(fn core ->
      Task.async(fn ->
        guess_in_parallel(rules, core * jump, offset)
      end)
    end)
    # This function will not return until every process has found an answer. We'll have to look at
    # stdout to see when the first one (the one we want) emits a result.
    |> Enum.map(fn job -> Task.await(job, :infinity) end)
  end

  defp guess_in_parallel(rules, attempt, offset) do
    Enum.all?(rules, fn
      {nil, _} -> true
      {x, delta} -> rem(attempt + delta - offset, x) == 0
    end)
    |> case do
      true ->
        IO.puts("The answer is #{attempt}")
        attempt

      false ->
        [{jump, _} | _] = rules
        guess_in_parallel(rules, attempt + @number_of_cores * jump, offset)
    end
  end

  @doc """
  This one requires math. The short version: for T = X*m - A and T = Y*n - B for some integers m
  and n, you can encode these requirements as T = (X*Y)*k - (X*M - A) for some integer k, where M
  is an integer between 0 and Y. Then, continue to apply the same logic to remaining requirements.

  Be sure to use the smaller of X and Y as the range for the loop.
  """
  @spec part_two_efficient :: number
  def part_two_efficient do
    input()
    |> List.last()
    |> parse_bus_ids()
    |> Enum.reduce(fn {x, x_offset}, {y, y_offset} ->
      mult =
        0..(x - 1)
        |> Enum.find(fn mult ->
          rem(y * mult - y_offset + x_offset, x) == 0
        end)

      {x * y, y_offset - mult * y}
    end)
    |> (fn {_, offset} -> -1 * offset end).()
  end
end
