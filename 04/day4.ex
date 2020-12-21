defmodule Day4 do
  #
  # Read and Parse
  #

  defp input do
    File.read!("04/input.txt")
    |> String.split("\n\n", trim: true)
  end

  #
  # Part One
  #

  @doc """
  For speed (of coding, not of the code) we can use String.contains?/2 to check for the necessary
  fields in each passport.
  """
  @spec part_one :: non_neg_integer
  def part_one do
    input()
    |> Enum.count(fn line ->
      String.contains?(line, "byr:") and
        String.contains?(line, "iyr:") and
        String.contains?(line, "eyr:") and
        String.contains?(line, "hgt:") and
        String.contains?(line, "hcl:") and
        String.contains?(line, "ecl:") and
        String.contains?(line, "pid:")
    end)
  end

  #
  # Part Two
  #

  @doc """
  In part two, we utilize regular expressions to capture passport data and iteratively filter the
  list of passports until all are valid.
  """
  @spec part_two :: non_neg_integer
  def part_two do
    input()
    |> Enum.filter(&valid_byr?/1)
    |> Enum.filter(&valid_iyr?/1)
    |> Enum.filter(&valid_eyr?/1)
    |> Enum.filter(&valid_hgt?/1)
    |> Enum.filter(&valid_hcl?/1)
    |> Enum.filter(&valid_ecl?/1)
    |> Enum.filter(&valid_pid?/1)
    |> Enum.count()
  end

  defp valid_byr?(line) do
    case Regex.named_captures(~r/byr:(?<byr>\d{4})(\s+|$)/, line) do
      %{"byr" => byr} -> String.to_integer(byr) >= 1920 and String.to_integer(byr) <= 2002
      nil -> false
    end
  end

  defp valid_iyr?(line) do
    case Regex.named_captures(~r/iyr:(?<iyr>\d{4})(\s+|$)/, line) do
      %{"iyr" => iyr} -> String.to_integer(iyr) >= 2010 and String.to_integer(iyr) <= 2020
      nil -> false
    end
  end

  defp valid_eyr?(line) do
    case Regex.named_captures(~r/eyr:(?<eyr>\d{4})(\s+|$)/, line) do
      %{"eyr" => eyr} -> String.to_integer(eyr) >= 2020 and String.to_integer(eyr) <= 2030
      nil -> false
    end
  end

  defp valid_hgt?(line) do
    case Regex.named_captures(~r/hgt:(?<hgt>\d+(cm|in))(\s+|$)/, line) do
      %{"hgt" => hgt} ->
        case Integer.parse(hgt) do
          {num, "cm"} when num >= 150 and num <= 193 -> true
          {num, "in"} when num >= 59 and num <= 76 -> true
          _ -> false
        end

      nil ->
        false
    end
  end

  defp valid_hcl?(line) do
    Regex.match?(~r/hcl:\#[0-9a-fA-F]{6}(\s+|$)/, line)
  end

  defp valid_ecl?(line) do
    Regex.match?(~r/ecl:(amb|blu|brn|gry|grn|hzl|oth)(\s+|$)/, line)
  end

  defp valid_pid?(line) do
    Regex.match?(~r/pid:\d{9}(\s+|$)/, line)
  end
end
