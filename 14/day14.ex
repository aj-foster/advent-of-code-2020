defmodule Day14 do
  def part_one do
    File.stream!("14/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn
      "mask = " <> mask ->
        mask = String.reverse(mask)
        {:mask, mask}

      "mem" <> rest ->
        %{"address" => addr, "value" => val} =
          Regex.named_captures(~r/\[(?<address>\d+)\] = (?<value>\d+)/, rest)

        val =
          val
          |> String.to_integer()
          |> Integer.to_string(2)
          |> String.pad_leading(36, "0")

        {:mem, addr, val}
    end)
    |> Enum.reduce({%{}, ""}, fn
      {:mask, mask}, {memory, _old_mask} ->
        {memory, mask}

      {:mem, address, value}, {memory, mask} ->
        value =
          value
          |> String.reverse()
          |> String.codepoints()
          |> Enum.with_index()
          |> Enum.map(fn {bit, index} ->
            case String.at(mask, index) do
              "X" -> bit
              "1" -> "1"
              "0" -> "0"
            end
          end)
          |> Enum.reverse()
          |> Enum.join()

        memory = Map.put(memory, address, value)

        {memory, mask}
    end)
    |> elem(0)
    |> Map.values()
    |> Enum.map(fn x -> String.to_integer(x, 2) end)
    |> Enum.reduce(&+/2)
  end

  def part_two do
    File.stream!("14/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn
      "mask = " <> mask ->
        mask = String.reverse(mask)
        {:mask, mask}

      "mem" <> rest ->
        %{"address" => addr, "value" => val} =
          Regex.named_captures(~r/\[(?<address>\d+)\] = (?<value>\d+)/, rest)

        addr =
          addr
          |> String.to_integer()
          |> Integer.to_string(2)
          |> String.pad_leading(36, "0")

        val = String.to_integer(val)

        {:mem, addr, val}
    end)
    |> Enum.reduce({%{}, ""}, fn
      {:mask, mask}, {memory, _old_mask} ->
        {memory, mask}

      {:mem, address, value}, {memory, mask} ->
        address_rev = String.reverse(address)

        memory =
          mask
          |> String.codepoints()
          |> Enum.with_index()
          |> Enum.reduce([[]], fn
            {"0", index}, list ->
              bit = String.at(address_rev, index)
              Enum.map(list, fn mask -> [bit | mask] end)

            {"1", _index}, list ->
              Enum.map(list, fn mask -> ["1" | mask] end)

            {"X", _index}, list ->
              Enum.map(list, fn mask -> ["0" | mask] end) ++
                Enum.map(list, fn mask -> ["1" | mask] end)
          end)
          |> Enum.map(&Enum.reverse/1)
          |> Enum.map(&Enum.join/1)
          |> Enum.reduce(memory, fn address, memory ->
            Map.put(memory, address, value)
          end)

        {memory, mask}
    end)
    |> elem(0)
    |> Map.values()
    |> Enum.reduce(&+/2)
  end
end
