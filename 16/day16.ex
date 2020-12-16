defmodule Day16 do
  def part_one do
    [rules, _ticket, nearby_tickets] =
      File.read!("16/input.txt")
      |> String.split("\n\n", trim: true)

    rules =
      rules
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        %{"low1" => low1, "high1" => high1, "low2" => low2, "high2" => high2} =
          Regex.named_captures(
            ~r/(?<low1>\d+)-(?<high1>\d+) or (?<low2>\d+)-(?<high2>\d+)/,
            line
          )

        {
          String.to_integer(low1),
          String.to_integer(high1),
          String.to_integer(low2),
          String.to_integer(high2)
        }
      end)

    nearby_tickets
    |> String.split("\n", trim: true)
    |> Enum.drop(1)
    |> Enum.map(fn ticket ->
      ticket
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> Enum.reject(fn number ->
        Enum.any?(rules, fn {low1, high1, low2, high2} ->
          (number >= low1 and number <= high1) or (number >= low2 and number <= high2)
        end)
      end)
      |> Enum.reduce(0, &+/2)
    end)
    |> Enum.reduce(0, &+/2)
  end

  def part_two do
    [rules, ticket, nearby_tickets] =
      File.read!("16/input.txt")
      |> String.split("\n\n", trim: true)

    ticket =
      ticket
      |> String.split("\n", trim: true)
      |> Enum.at(1)
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    rules =
      rules
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        %{"name" => name, "low1" => low1, "high1" => high1, "low2" => low2, "high2" => high2} =
          Regex.named_captures(
            ~r/(?<name>.*)\: (?<low1>\d+)-(?<high1>\d+) or (?<low2>\d+)-(?<high2>\d+)/,
            line
          )

        {
          name,
          String.to_integer(low1),
          String.to_integer(high1),
          String.to_integer(low2),
          String.to_integer(high2)
        }
      end)

    rules_map =
      rules
      |> Enum.reduce(%{}, fn {name, a, b, c, d}, acc -> Map.put(acc, name, {a, b, c, d}) end)

    possibilities =
      0..(length(ticket) - 1)
      |> Enum.map(fn _ -> Map.keys(rules_map) |> MapSet.new() end)

    fields =
      nearby_tickets
      |> String.split("\n", trim: true)
      |> Enum.drop(1)
      |> Enum.filter(fn ticket ->
        ticket
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> Enum.all?(fn number ->
          Enum.any?(rules, fn {_name, low1, high1, low2, high2} ->
            (number >= low1 and number <= high1) or (number >= low2 and number <= high2)
          end)
        end)
      end)
      |> Enum.reduce(possibilities, fn ticket, acc ->
        ticket
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {number, index}, acc2 ->
          revised_possibilities =
            Enum.at(acc2, index)
            |> Enum.filter(fn rule_name ->
              {low1, high1, low2, high2} = Map.fetch!(rules_map, rule_name)
              (number >= low1 and number <= high1) or (number >= low2 and number <= high2)
            end)
            |> MapSet.new()

          List.replace_at(acc2, index, revised_possibilities)
        end)
      end)
      |> Enum.with_index()
      |> Enum.sort_by(fn {set, _index} -> MapSet.size(set) end)
      |> Enum.reduce({%{}, []}, fn {set, index}, {possibilities, seen} ->
        set = MapSet.difference(set, MapSet.new(seen))
        [result] = MapSet.to_list(set)
        {Map.put(possibilities, result, index), [result | seen]}
      end)
      |> elem(0)
      |> Enum.to_list()
      |> Enum.sort_by(fn {_name, index} -> index end)
      |> Enum.map(fn {name, _index} -> name end)

    fields
    |> Enum.with_index()
    |> Enum.reduce(1, fn
      {"departure" <> _rest, index}, sum ->
        sum * Enum.at(ticket, index)

      _, sum ->
        sum
    end)
  end
end
