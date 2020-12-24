defmodule Day7 do
  #
  # Read and Parse
  #

  defp input do
    File.stream!("07/input.txt")
    |> Stream.map(&parse_line/1)
    |> Enum.to_list()
    |> List.flatten()
  end

  @line_regex ~r/(?<container>.*) bags contain (?<inside>.*)\.$/
  @contents_regex ~r/(?<count>\d+) (?<bag>.*) bags?/

  defp parse_line(line) do
    %{"container" => container, "inside" => inside} = Regex.named_captures(@line_regex, line)

    String.split(inside, ", ", trim: true)
    |> Enum.map(&parse_contents/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn {bag, count} -> {container, bag, count} end)
  end

  defp parse_contents(contents) do
    case Regex.named_captures(@contents_regex, contents) do
      %{"bag" => bag, "count" => count} -> {bag, String.to_integer(count)}
      nil -> nil
    end
  end

  #
  # Part One
  #

  @doc """
  For part one, we create a map from bags -> containing bags. We then recursively look up exterior
  bags, starting with the shiny gold bag we have.
  """
  @spec part_one :: non_neg_integer
  def part_one do
    input()
    |> Enum.reduce(%{}, &map_interior_to_container/2)
    |> gather_containers("shiny gold")
    |> Enum.uniq()
    |> Enum.count()
  end

  defp map_interior_to_container({container, inside, _count}, map) do
    Map.update(map, inside, [container], &[container | &1])
  end

  defp gather_containers(graph, bag, list \\ []) do
    Map.get(graph, bag, [])
    |> Enum.reduce(Map.get(graph, bag, []), &gather_containers(graph, &1, &2))
    |> Kernel.++(list)
  end

  #
  # Part Two
  #

  @doc """
  For part two, we flip the map to go from bags -> containing bags, and include counts. We then
  recursively count the contents, multiplying by the counts as appropriate.
  """
  @spec part_two :: non_neg_integer
  def part_two do
    input()
    |> Enum.reduce(%{}, &map_container_to_contents/2)
    |> gather_contents("shiny gold")
  end

  defp map_container_to_contents({container, inside, count}, map) do
    Map.update(map, container, [{inside, count}], &[{inside, count} | &1])
  end

  defp gather_contents(graph, bag) do
    Map.get(graph, bag, [])
    |> Enum.map(fn {inside, count} -> count * (gather_contents(graph, inside) + 1) end)
    |> Enum.sum()
  end
end
