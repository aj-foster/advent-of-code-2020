defmodule Day21 do
  @regex ~r/^(?<ingredients>.*) \(contains (?<allergens>.*)\)$/
  def part_one do
    input =
      File.stream!("21/input.txt")
      |> Stream.map(&String.trim/1)
      |> Stream.map(fn line -> Regex.named_captures(@regex, line) end)
      |> Stream.map(fn %{"ingredients" => i, "allergens" => a} -> {i, a} end)
      |> Stream.map(fn {i, a} ->
        {
          String.split(i, " ", trim: true),
          String.split(a, ", ", trim: true)
        }
      end)

    allergen_candidates =
      input
      |> Enum.reduce(%{}, fn {i, a}, acc ->
        Enum.reduce(a, acc, fn allergen, acc ->
          Map.update(acc, allergen, MapSet.new(i), fn candidates ->
            MapSet.intersection(candidates, MapSet.new(i))
          end)
        end)
      end)
      |> Enum.reduce(MapSet.new(), fn {_allergen, candidates}, set ->
        MapSet.union(set, candidates)
      end)

    all_ingredients =
      input
      |> Enum.reduce(MapSet.new(), fn {i, _a}, set -> MapSet.union(set, MapSet.new(i)) end)

    non_allergenic = MapSet.difference(all_ingredients, allergen_candidates)

    input
    |> Enum.reduce([], fn {i, _a}, list -> i ++ list end)
    |> Enum.count(fn x -> MapSet.member?(non_allergenic, x) end)
  end

  def part_two do
    input =
      File.stream!("21/input.txt")
      |> Stream.map(&String.trim/1)
      |> Stream.map(fn line -> Regex.named_captures(@regex, line) end)
      |> Stream.map(fn %{"ingredients" => i, "allergens" => a} -> {i, a} end)
      |> Stream.map(fn {i, a} ->
        {
          String.split(i, " ", trim: true),
          String.split(a, ", ", trim: true)
        }
      end)

    input
    |> Enum.reduce(%{}, fn {i, a}, acc ->
      Enum.reduce(a, acc, fn allergen, acc ->
        Map.update(acc, allergen, MapSet.new(i), fn candidates ->
          MapSet.intersection(candidates, MapSet.new(i))
        end)
      end)
    end)
    |> eliminate_candidates()
    |> Enum.sort_by(fn {_ingredient, allergen} -> allergen end)
    |> Enum.map(fn {ingredient, _allergen} -> ingredient end)
    |> Enum.join(",")
  end

  defp eliminate_candidates(candidates, confirmed \\ %{})
  defp eliminate_candidates(candidates, confirmed) when map_size(candidates) == 0, do: confirmed

  defp eliminate_candidates(candidates, confirmed) do
    {allergen, ingredient_set} = Enum.find(candidates, fn {_a, c} -> MapSet.size(c) == 1 end)
    [ingredient] = MapSet.to_list(ingredient_set)

    candidates =
      candidates
      |> Enum.map(fn {a, c} -> {a, MapSet.delete(c, ingredient)} end)
      |> Enum.into(%{})
      |> Map.delete(allergen)

    confirmed = Map.put(confirmed, ingredient, allergen)

    eliminate_candidates(candidates, confirmed)
  end
end
