defmodule Day4 do
  def part_one do
    File.read!("04/input.txt")
    |> String.split("\n\n", trim: true)
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

  def part_two do
    File.read!("04/input.txt")
    |> String.split("\n\n", trim: true)
    |> Enum.filter(fn line ->
      String.contains?(line, "byr:") and
        String.contains?(line, "iyr:") and
        String.contains?(line, "eyr:") and
        String.contains?(line, "hgt:") and
        String.contains?(line, "hcl:") and
        String.contains?(line, "ecl:") and
        String.contains?(line, "pid:")
    end)
    |> Enum.count(fn line ->
      try do
        %{"byr" => byr} = Regex.named_captures(~r/byr:(?<byr>\d{4})(\s+|$)/, line)
        %{"iyr" => iyr} = Regex.named_captures(~r/iyr:(?<iyr>\d{4})(\s+|$)/, line)
        %{"eyr" => eyr} = Regex.named_captures(~r/eyr:(?<eyr>\d{4})(\s+|$)/, line)
        %{"hgt" => hgt} = Regex.named_captures(~r/hgt:(?<hgt>\d+(cm|in))(\s+|$)/, line)
        %{"hcl" => hcl} = Regex.named_captures(~r/hcl:(?<hcl>\#[0-9a-fA-F]{6})(\s+|$)/, line)

        %{"ecl" => ecl} =
          Regex.named_captures(~r/ecl:(?<ecl>(amb|blu|brn|gry|grn|hzl|oth))(\s+|$)/, line)

        %{"pid" => pid} = Regex.named_captures(~r/pid:(?<pid>\d{9})(\s+|$)/, line)

        String.to_integer(byr) >= 1920 and String.to_integer(byr) <= 2002 and
          (String.to_integer(iyr) >= 2010 and String.to_integer(iyr) <= 2020) and
          String.to_integer(eyr) >= 2020 and String.to_integer(eyr) <= 2030 and
          case Integer.parse(hgt) do
            {num, "cm"} when num >= 150 and num <= 193 -> true
            {num, "in"} when num >= 59 and num <= 76 -> true
            _ -> false
          end
      rescue
        e in [MatchError] ->
          IO.inspect(e)
          false
      end
    end)
  end
end
