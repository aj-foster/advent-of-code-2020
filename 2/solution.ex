defmodule Solution do
  def input do
    File.stream!("input.txt")
    |> Stream.filter(&(byte_size(&1) > 1))
    |> Stream.map(fn line ->
      Regex.named_captures(~r/(?<low>\d+)-(?<high>\d+)\s*(?<letter>\w):\s*(?<pass>\w+)/, line)
    end)
    |> Stream.map(fn %{"letter" => letter, "pass" => pass, "low" => low, "high" => high} = line ->
      count =
        String.codepoints(pass)
        |> Enum.filter(&(&1 == letter))
        |> Enum.count()

      line
      |> Map.put("count", count)
      |> Map.put("low", String.to_integer(low))
      |> Map.put("high", String.to_integer(high))
      |> IO.inspect()
    end)
    |> Stream.filter(fn %{"low" => low, "count" => count, "high" => high} ->
      low <= count and count <= high
    end)
    |> Enum.count()
  end

  def input2 do
    File.stream!("input.txt")
    |> Stream.filter(&(byte_size(&1) > 1))
    |> Stream.map(fn line ->
      Regex.named_captures(~r/(?<first>\d+)-(?<second>\d+)\s*(?<letter>\w):\s*(?<pass>\w+)/, line)
    end)
    |> Stream.map(fn %{"pass" => pass, "first" => first, "second" => second} = line ->
      line
      |> Map.put("first", String.to_integer(first))
      |> Map.put("second", String.to_integer(second))
    end)
    |> Stream.filter(fn %{
                          "first" => first,
                          "second" => second,
                          "letter" => letter,
                          "pass" => pass
                        } ->
      try do
        list = String.to_charlist(pass)
        first_letter = [Enum.at(list, first - 1)] |> List.to_string()
        second_letter = [Enum.at(list, second - 1)] |> List.to_string()

        case IO.inspect({first_letter, second_letter}) do
          {^letter, ^letter} -> false
          {^letter, _} -> true
          {_, ^letter} -> true
          {_, _} -> false
        end
      rescue
        ArgumentError -> false
      end
    end)
    |> Enum.count()
  end
end
