defmodule Day6 do
  def part_one do
    File.read!("06/input.txt")
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn group ->
      # group
      # |> String.split("\n", trim: true)
      # |> Enum.map(fn person ->
      #   String.codepoints()
      #   |> Enum.uniq()
      # end)

      group
      |> String.replace(~r/[^a-z]/, "")
      |> String.codepoints()
      |> Enum.uniq()
      |> Enum.count()
    end)
    |> Enum.reduce(&+/2)
  end

  def part_two do
    File.read!("06/input.txt")
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn group ->
      counts =
        String.split(group, "\n", trim: true)
        |> Enum.reduce(%{}, fn person, acc ->
          person
          |> String.codepoints()
          |> Enum.uniq()
          |> Enum.reduce(acc, fn x, acc ->
            Map.update(acc, x, 1, &(&1 + 1))
          end)
          |> Map.update("total", 1, &(&1 + 1))
        end)

      total = Map.get(counts, "total")

      counts
      |> Map.delete("total")
      |> Enum.filter(fn {_letter, count} -> count == total end)
      |> Enum.count()
    end)
    |> Enum.reduce(&+/2)
  end
end
