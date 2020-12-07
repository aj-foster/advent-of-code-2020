defmodule Day7 do
  def part_one do
    File.stream!("07/input.txt")
    |> Stream.map(fn line ->
      %{"container" => container, "inside" => inside} =
        Regex.named_captures(~r/(?<container>.*) bags contain (?<inside>.*)\.$/, line)

      String.split(inside, ", ", trim: true)
      |> Enum.map(fn phrase ->
        case Regex.named_captures(~r/\d+ (?<bag>.*) bags?/, phrase) do
          %{"bag" => bag} -> {bag, container}
          nil -> nil
        end
      end)
    end)
    |> Enum.to_list()
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(%{}, fn {inside, outside}, acc ->
      Map.update(acc, inside, [outside], &[outside | &1])
    end)
    |> do_stuff("shiny gold")
    |> Enum.uniq()
    |> Enum.count()
  end

  defp do_stuff(graph, bag, list \\ []) do
    Map.get(graph, bag, [])
    |> Enum.reduce(Map.get(graph, bag, []), &do_stuff(graph, &1, &2))
    |> Kernel.++(list)
  end

  def part_two do
    File.stream!("07/input.txt")
    |> Stream.map(fn line ->
      %{"container" => container, "inside" => inside} =
        Regex.named_captures(~r/(?<container>.*) bags contain (?<inside>.*)\.$/, line)

      String.split(inside, ", ", trim: true)
      |> Enum.map(fn phrase ->
        case Regex.named_captures(~r/(?<count>\d+) (?<bag>.*) bags?/, phrase) do
          %{"bag" => bag, "count" => count} -> {container, bag, String.to_integer(count)}
          nil -> nil
        end
      end)
    end)
    |> Enum.to_list()
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(%{}, fn {outside, inside, count}, acc ->
      Map.update(acc, outside, [{inside, count}], &[{inside, count} | &1])
    end)
    |> IO.inspect()
    |> do_more_stuff("shiny gold")
  end

  defp do_more_stuff(graph, bag) do
    case Map.get(graph, bag) do
      nil ->
        0

      list ->
        list
        |> Enum.map(fn {inside, count} -> count * (do_more_stuff(graph, inside) + 1) end)
        |> Enum.reduce(&+/2)
    end
  end
end
