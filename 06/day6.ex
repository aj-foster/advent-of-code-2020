defmodule Day6 do
  #
  # Read and Parse
  #

  defp input do
    File.read!("06/input.txt")
    |> String.split("\n\n", trim: true)
  end

  #
  # Part One
  #

  @doc """
  This first solution is not particularly efficient, as it loops through the data multiple times
  on its way to a solution. The thesis is that we can treat each group (as delineated by double-
  newlines) as a group of characters. Converting the characters to a list of single-character
  strings, and then counting the unique members, gets us the total for each group. Afterwards we
  can reduce using the + function (formally, it's `Kernel.+/2`). Using the capture syntax for it
  might seem weird, but I enjoy the way it removes most of the extra verbage from around the
  operation taking place. That is, of course, if you know to ignore the slash.
  """
  @spec part_one_strings :: number
  def part_one_strings do
    input()
    |> Enum.map(&count_questions/1)
    |> Enum.sum()
  end

  defp count_questions(group) do
    group
    |> String.replace(~r/[^a-z]/, "")
    |> String.codepoints()
    |> Enum.uniq()
    |> Enum.count()
  end

  @doc """
  The goal of this second method is efficiency, although in reality it could be done much faster
  at a lower level. Conceptually, I want to loop through each byte from the file only once, and
  keep a running count as we go.

  The `reducer/2` helper is doing most of the heavy listing. Understanding it requires understanding
  the tuple being passed around as the accumulator:

      {
        sum,                Running total of all previous group counts.
        letters,            MapSet containing letters found in the current group.
        just_saw_newline?   Whether the parser just saw "\\n". Relevant for finding double-newlines.
      }

  As we observe each letter, we change the state of the accumulator tuple. In the end, we need to
  flush the last of the changes through — since there's no double-newline at the end of the file
  to signal the end of the final group.
  """
  @spec part_one_bytewise :: number
  def part_one_bytewise do
    File.stream!("06/input.txt", [], 1)
    |> Enum.reduce({0, MapSet.new(), false}, &reducer/2)
    |> finalize()
  end

  # Upon a first newline, do nothing, but note that we've seen one.
  defp reducer("\n", {sum, letters, false}), do: {sum, letters, true}

  # Upon a second newline in a row, add the current count to the total and reset for the next group.
  defp reducer("\n", {sum, letters, true}), do: {sum + MapSet.size(letters), MapSet.new(), false}

  # Upon a letter, add to the set of observed letters for this group.
  defp reducer(letter, {sum, letters, _bool}), do: {sum, MapSet.put(letters, letter), false}

  # Add up any leftover letters from the last group, which did not get finalized with two newlines.
  defp finalize({sum, letters, _bool}), do: sum + MapSet.size(letters)

  #
  # Part Two
  #

  @doc """
  This solution is also not particularly efficient. For each group, we calculate the number of times
  each letter appears and compare it with the total number of people. When the letter appears the
  same number of times as the number of people, then it must have appeared for everyone.
  """
  @spec part_two :: number
  def part_two do
    input()
    |> Enum.map(&count_responses_by_letter/1)
    |> Enum.sum()
  end

  defp count_responses_by_letter(group) do
    lines = String.split(group, "\n", trim: true)
    total = length(lines)

    lines
    |> Enum.reduce(%{}, &reduce_letter_count/2)
    |> Enum.count(fn {_letter, count} -> count == total end)
  end

  defp reduce_letter_count(person, counts) do
    person
    |> String.codepoints()
    |> Enum.reduce(counts, fn letter, counts ->
      Map.update(counts, letter, 1, &(&1 + 1))
    end)
  end
end
