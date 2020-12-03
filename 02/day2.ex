defmodule Day2 do
  #
  # Reading the File
  #

  @doc """
  Read the file, line-by-line, and filter out any lines smaller than 2 bytes (blank lines).
  """
  @spec input :: Stream.t()
  def input do
    File.stream!("02/input.txt")
    |> Stream.filter(&(byte_size(&1) > 1))
  end

  @doc """
  We can parse the file using regular expressions. I like `Regex.named_captures/3` because it lets
  you name the parts of the regular expression you're interested in.
  """
  @spec parse_regex(Stream.t()) :: Stream.t()
  def parse_regex(stream) do
    Stream.map(stream, fn line ->
      Regex.named_captures(~r/(?<low>\d+)-(?<high>\d+)\s*(?<letter>\w):\s*(?<pass>\w+)/, line)
      |> Map.update!("low", &String.to_integer/1)
      |> Map.update!("high", &String.to_integer/1)
    end)
  end

  @doc """
  We can also parse the file using binary pattern matching. This works because there aren't too
  many variations in the sizing of the parts (only the numbers might change size to be one or two
  digits) and the part with the most variation, the password, is at the very end.

  When we capture the numbers, they are expressed as decimal integers. We can use character math
  (the fact that "0" is ASCII character 48) to quickly adjust the values into integers. For two
  digit numbers, multiply by the place number (10 or 1) as appropriate.

  ?x is a quick way to get the ASCII code for a character, and <<x>> will move from the ASCII code
  back to a string.
  """
  @spec parse_binary(Stream.t()) :: Stream.t()
  def parse_binary(stream) do
    Stream.map(stream, fn
      # X-Y L: ...
      <<low, ?-, high, _, letter::binary-1, ?:, _, pass::binary>> ->
        %{"low" => low - 48, "high" => high - 48, "letter" => letter, "pass" => pass}

      # X-YY L: ...
      <<low, ?-, h1, h2, _, letter::binary-1, ?:, _, pass::binary>> ->
        %{
          "low" => low - 48,
          "high" => 10 * (h1 - 48) + (h2 - 48),
          "letter" => letter,
          "pass" => pass
        }

      # XX-YY L: ...
      <<l1, l2, ?-, h1, h2, _, letter::binary-1, ?:, _, pass::binary>> ->
        %{
          "low" => 10 * (l1 - 48) + (l2 - 48),
          "high" => 10 * (h1 - 48) + (h2 - 48),
          "letter" => letter,
          "pass" => pass
        }
    end)
  end

  #
  # Part One
  #

  @spec part_one :: non_neg_integer
  def part_one do
    input()
    |> parse_binary()
    |> Stream.filter(fn %{"low" => low, "high" => high, "letter" => letter, "pass" => pass} ->
      count =
        String.codepoints(pass)
        |> Enum.count(&(&1 == letter))

      low <= count and count <= high
    end)
    |> Enum.count()
  end

  #
  # Part Two
  #

  @spec part_two :: non_neg_integer
  def part_two do
    input()
    |> parse_binary()
    |> Stream.filter(fn %{"low" => low, "high" => high, "letter" => letter, "pass" => pass} ->
      list = String.to_charlist(pass)
      first_letter = <<Enum.at(list, low - 1)>>
      second_letter = <<Enum.at(list, high - 1)>>

      case {first_letter, second_letter} do
        {^letter, ^letter} -> false
        {^letter, _} -> true
        {_, ^letter} -> true
        {_, _} -> false
      end
    end)
    |> Enum.count()
  end
end
