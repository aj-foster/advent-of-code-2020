defmodule Day16 do
  #
  # Read and Parse
  #

  defp input do
    [rules_str, ticket_str, nearby_tickets_str] =
      File.read!("16/input.txt")
      |> String.split("\n\n", trim: true)

    {
      parse_rules(rules_str),
      parse_ticket(ticket_str),
      parse_nearby_tickets(nearby_tickets_str)
    }
  end

  @rules_regex ~r/(?<name>.*)\: (?<low1>\d+)-(?<high1>\d+) or (?<low2>\d+)-(?<high2>\d+)/

  defp parse_rules(input_str) do
    input_str
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      %{"name" => name, "low1" => low1, "high1" => high1, "low2" => low2, "high2" => high2} =
        Regex.named_captures(@rules_regex, line)

      {
        name,
        String.to_integer(low1),
        String.to_integer(high1),
        String.to_integer(low2),
        String.to_integer(high2)
      }
    end)
  end

  defp parse_ticket(ticket_str) do
    ticket_str
    |> String.split("\n", trim: true)
    |> Enum.at(1)
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_nearby_tickets(nearby_tickets_str) do
    nearby_tickets_str
    |> String.split("\n", trim: true)
    |> Enum.drop(1)
    |> Enum.map(fn ticket ->
      ticket
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  #
  # Part One
  #

  @spec part_one :: number
  def part_one do
    {rules, _ticket, nearby_tickets} = input()

    nearby_tickets
    |> Enum.map(fn ticket ->
      ticket
      |> Enum.reject(fn number -> valid_number?(number, rules) end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  defp valid_number?(number, rules) do
    Enum.any?(rules, fn {_name, low1, high1, low2, high2} ->
      (number >= low1 and number <= high1) or (number >= low2 and number <= high2)
    end)
  end

  #
  # Part Two
  #

  @spec part_two :: number
  def part_two do
    {rules, ticket, nearby_tickets} = input()

    nearby_tickets
    |> reject_invalid_tickets(rules)
    |> find_possibilities_by_index(rules)
    |> gaussian_eliminate_possibilities()
    |> multiply_departure_fields(ticket)
  end

  defp reject_invalid_tickets(tickets, rules) do
    Enum.filter(tickets, fn ticket ->
      Enum.all?(ticket, fn number -> valid_number?(number, rules) end)
    end)
  end

  defp find_possibilities_by_index(tickets, rules) do
    rules_map =
      Enum.reduce(rules, %{}, fn {name, a, b, c, d}, acc -> Map.put(acc, name, {a, b, c, d}) end)

    ticket_length = List.first(tickets) |> length()

    possibilities =
      0..(ticket_length - 1)
      |> Enum.map(fn _ -> Map.keys(rules_map) |> MapSet.new() end)

    Enum.reduce(tickets, possibilities, fn ticket, acc ->
      ticket
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
  end

  defp gaussian_eliminate_possibilities(tickets) do
    tickets
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
  end

  defp multiply_departure_fields(fields, ticket) do
    fields
    |> Enum.with_index()
    |> Enum.reduce(1, fn
      {"departure" <> _rest, index}, product ->
        product * Enum.at(ticket, index)

      _, product ->
        product
    end)
  end
end
