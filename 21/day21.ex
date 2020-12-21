defmodule Day21 do
  #
  # Read and Parse
  #

  @regex ~r/^(?<ingredients>.*) \(contains (?<allergens>.*)\)$/

  @spec input :: [{ingredients :: [String.t()], allergens :: [String.t()]}]
  defp input do
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
    |> Enum.to_list()
  end

  #
  # Part One
  #

  @doc """
  Every time we see an allergen, the associated ingredients form a set of candidates. We can
  narrow down the candidates by intersecting each set of candidates. By the end, we get a map
  that associates each allergen with a list of possible matching ingredients. We expect the
  number of allergens and the number of ingredients (without duplicates) to match.
  """
  @spec part_one :: non_neg_integer
  def part_one do
    input = input()
    all_ingredients_with_duplicates = all_ingredients_with_duplicates(input)
    all_ingredients = MapSet.new(all_ingredients_with_duplicates)

    allergen_candidates =
      allergen_candidates(input)
      |> get_ingredients()

    non_allergenic = MapSet.difference(all_ingredients, allergen_candidates)

    Enum.count(all_ingredients_with_duplicates, fn x -> MapSet.member?(non_allergenic, x) end)
  end

  # For each item of food, and for each allergen, take the intersection of existing candidates
  # (if any) with the new list of ingredients. If this is the first time we're seeing an allergen,
  # the full ingredient list becomes the set of candidates.
  #
  defp allergen_candidates(input) do
    input
    |> Enum.reduce(%{}, fn {i, a}, acc ->
      Enum.reduce(a, acc, fn allergen, acc ->
        # Intersect an existing set, or define a new one for the first time.
        Map.update(acc, allergen, MapSet.new(i), fn candidates ->
          MapSet.intersection(candidates, MapSet.new(i))
        end)
      end)
    end)
  end

  # Get a single set with all ingredients that contain allergens.
  defp get_ingredients(candidate_map) do
    Enum.reduce(candidate_map, MapSet.new(), fn {_allergen, candidates}, set ->
      MapSet.union(set, candidates)
    end)
  end

  # For counting purposes, we need a list of all ingredients with duplicates.
  defp all_ingredients_with_duplicates(input) do
    input
    |> Enum.map(fn {i, _a} -> i end)
    |> List.flatten()
  end

  #
  # Part Two
  #

  @doc """
  Leveraging the work to calculate allergen candidate ingredients from part one, we can narrow
  down the remaining associations even further until we have a 1:1 correspondence between allergen
  and ingredient. Then, sort by allergen and list the ingredients.
  """
  @spec part_two :: String.t()
  def part_two do
    input = input()

    input
    |> allergen_candidates()
    |> eliminate_candidates()
    |> Enum.sort_by(fn {_ingredient, allergen} -> allergen end)
    |> Enum.map(fn {ingredient, _allergen} -> ingredient end)
    |> Enum.join(",")
  end

  # Use any allergen -> ingredients association with only one candidate ingredient to perform a
  # kind of Gaussian elimination on the map of all candidates. In the end, we expect to have only
  # one ingredient per allergen.
  #
  # As the recursion occurs, we gradually shift allergens from the original candidate map into a
  # new `confirmed` map that only has 1:1 associations.
  #
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
