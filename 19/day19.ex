defmodule Day19 do
  defp input do
    File.stream!("19/input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_input/1)
  end

  defp parse_input(""), do: nil
  defp parse_input("a" <> rest), do: {:msg, "a" <> rest}
  defp parse_input("b" <> rest), do: {:msg, "b" <> rest}

  defp parse_input(rule) do
    Regex.named_captures(
      ~r/(?<rule>\d+)\: (((?<r11>\d+)( (?<r12>\d+))?( (?<r13>\d+))?( \| (?<r21>\d+)( (?<r22>\d+))?)?)|("(?<letter>\w)"))/,
      rule
    )
    |> Map.update!("rule", &String.to_integer/1)
    |> Enum.reject(fn {_key, value} -> value == "" end)
    |> Enum.into(%{})
    |> case do
      %{"letter" => letter, "rule" => rule} ->
        {:rule, rule, letter}

      %{"r11" => r11, "r12" => r12, "r21" => r21, "r22" => r22, "rule" => rule} ->
        r11 = String.to_integer(r11)
        r12 = String.to_integer(r12)
        r21 = String.to_integer(r21)
        r22 = String.to_integer(r22)
        {:rule, rule, {[r11, r12], [r21, r22]}}

      %{"r11" => r11, "r21" => r21, "rule" => rule} ->
        r11 = String.to_integer(r11)
        r21 = String.to_integer(r21)
        {:rule, rule, {[r11], [r21]}}

      %{"r11" => r11, "r12" => r12, "r13" => r13, "rule" => rule} ->
        r11 = String.to_integer(r11)
        r12 = String.to_integer(r12)
        r13 = String.to_integer(r13)
        {:rule, rule, [r11, r12, r13]}

      %{"r11" => r11, "r12" => r12, "rule" => rule} ->
        r11 = String.to_integer(r11)
        r12 = String.to_integer(r12)
        {:rule, rule, [r11, r12]}

      %{"r11" => r11, "rule" => rule} ->
        r11 = String.to_integer(r11)
        {:rule, rule, r11}
    end
  end

  #
  # Part One
  #

  def part_one do
    stream = input()

    rules =
      stream
      |> Stream.filter(&match?({:rule, _, _}, &1))
      |> Enum.to_list()
      |> Enum.sort_by(fn {:rule, num, _rule} -> num end, :desc)
      |> process_rules()

    stream
    |> Stream.filter(&match?({:msg, _}, &1))
    |> Stream.map(&elem(&1, 1))
    # |> Stream.filter(&(String.length(&1) in List.flatten(valid?(&1, rules))))
    |> Stream.filter(&valid?(&1, rules))
    # |> Stream.filter(fn line -> Regex.match?(rules, line) end)
    |> Enum.count()
  end

  defp process_rules([{:rule, 0, rule}]), do: rule

  defp process_rules([{:rule, num, rule} | rest]) do
    rest
    |> Enum.map(fn {:rule, n, r} -> {:rule, n, replace_rule(r, num, rule)} end)
    |> process_rules()
  end

  defp replace_rule("a", _, _), do: "a"
  defp replace_rule("b", _, _), do: "b"
  defp replace_rule(target, target, replacement), do: replacement
  defp replace_rule(num, _, _) when is_number(num), do: num

  defp replace_rule(rule, target, replacement) when is_list(rule) do
    Enum.map(rule, &replace_rule(&1, target, replacement))
  end

  defp replace_rule({rule1, rule2}, target, replacement) do
    {replace_rule(rule1, target, replacement), replace_rule(rule2, target, replacement)}
  end

  # defp process_rules([{:rule, 0, rule}]) do
  #   string = List.flatten(rule) |> Enum.join()
  #   Regex.compile!("^" <> string <> "$")
  # end

  # defp process_rules([{:rule, num, rule} | rest]) do
  #   rest
  #   |> Enum.map(fn {:rule, n, r} -> {:rule, n, replace_rule(r, num, rule)} end)
  #   |> process_rules()
  # end

  # defp replace_rule("a", _, _), do: "a"
  # defp replace_rule("b", _, _), do: "b"
  # defp replace_rule(target, target, replacement), do: replacement
  # defp replace_rule(num, _, _) when is_number(num), do: num
  # defp replace_rule(char, _, _) when is_binary(char), do: char

  # defp replace_rule(rule, target, replacement) when is_list(rule) do
  #   Enum.map(rule, &replace_rule(&1, target, replacement))
  # end

  # defp replace_rule({rule1, rule2}, target, replacement) do
  #   [
  #     "(",
  #     replace_rule(rule1, target, replacement),
  #     "|",
  #     replace_rule(rule2, target, replacement),
  #     ")"
  #   ]
  # end

  # defp valid?(message, rules)

  # defp valid?(msg, []), do: byte_size(msg) == 0
  # defp valid?("a" <> _rest, "a"), do: true
  # defp valid?("a" <> _rest, "b"), do: false
  # defp valid?("b" <> _rest, "b"), do: true
  # defp valid?("b" <> _rest, "a"), do: false
  # defp valid?(msg, {rule1, rule2}), do: valid?(msg, rule1) or valid?(msg, rule2)

  # defp valid?(msg, [rule | rest]) do
  #   valid?(msg, rule) and valid?(m, rest)
  # end

  # defp valid?(message, rules, count \\ 0)

  # defp valid?("", _, count), do: count
  # defp valid?(_msg, [], count), do: count
  # defp valid?("a" <> _rest, "a", counts) when is_list(counts), do: Enum.map(counts, &(&1 + 1))
  # defp valid?("b" <> _rest, "b", counts) when is_list(counts), do: Enum.map(counts, &(&1 + 1))
  # defp valid?("a" <> _rest, "a", count), do: count + 1
  # defp valid?("b" <> _rest, "b", count), do: count + 1
  # defp valid?("a" <> _rest, "b", count), do: count
  # defp valid?("b" <> _rest, "a", count), do: count

  # defp valid?(msg, {r1, r2}, c), do: List.flatten([valid?(msg, r1, c), valid?(msg, r2, c)])

  # defp valid?(msg, [rule | rest], count) do
  #   case valid?(msg, rule, count) do
  #     counts when is_list(counts) ->
  #       counts
  #       |> List.flatten()
  #       |> Enum.map(fn count ->
  #         valid?(String.slice(msg, count..-1), rest, count)
  #       end)

  #     count ->
  #       msg = String.slice(msg, count..-1)
  #       valid?(msg, rest, count)
  #   end
  # end

  #  defp valid?(message, rules)

  defp valid?("a" <> rest, ["a" | rules]), do: valid?(rest, rules)
  defp valid?("b" <> rest, ["b" | rules]), do: valid?(rest, rules)
  defp valid?("a" <> _rest, ["b" | _]), do: false
  defp valid?("b" <> _rest, ["a" | _]), do: false

  defp valid?(msg, [[rule1, rule2] | rules]) do
    valid?(msg, [rule1, rule2 | rules])
  end

  defp valid?(msg, [{rule1, rule2} | rules]) do
    valid?(msg, rule1 ++ rules) or valid?(msg, rule2 ++ rules)
  end

  defp valid?("", []), do: true
  defp valid?("", _rules), do: false
  defp valid?(_msg, []), do: false

  # defp valid?(message, rules)

  # defp valid?(_msg, []), do: 0
  # defp valid?("a" <> _rest, "a"), do: 1
  # defp valid?("b" <> _rest, "b"), do: 1
  # defp valid?("a" <> _rest, "b"), do: 0
  # defp valid?("b" <> _rest, "a"), do: 0

  # defp valid?(msg, {r1, r2}), do: max(valid?(msg, r1), valid?(msg, r2))

  # defp valid?(msg, [rule | rest]) do
  #   count = valid?(msg, rule)
  #   msg = String.slice(msg, count..-1)
  #   valid?(msg, rest)
  # end

  #
  # Part Two
  #

  def part_two do
    stream = input()

    rules =
      stream
      |> Stream.filter(&match?({:rule, _, _}, &1))
      |> Stream.map(&patch_rules/1)
      |> Enum.to_list()
      |> Enum.sort_by(fn {:rule, num, _rule} -> num end, :desc)
      |> process_rules2()

    stream
    |> Stream.filter(&match?({:msg, _}, &1))
    |> Stream.map(&elem(&1, 1))
    # |> Stream.filter(&(String.length(&1) in List.flatten(valid?(&1, rules))))
    |> Stream.filter(&valid?(&1, rules))
    # |> Stream.filter(fn line -> Regex.match?(rules, line) end)
    |> Enum.count()
  end

  defp patch_rules({:rule, 8, 42}), do: {:rule, 8, {[42], [42, 8]}}
  defp patch_rules({:rule, 11, [42, 31]}), do: {:rule, 11, {[42, 31], [42, 11, 31]}}
  defp patch_rules(other), do: other

  defp process_rules2([{:rule, 0, rule}]), do: rule

  defp process_rules2([{:rule, num, rule} | rest]) when num == 8 or num == 11 do
    rule =
      Enum.reduce(1..100, rule, fn _, r -> replace_rule(r, num, rule) end)
      |> replace_rule(8, 42)
      |> replace_rule(11, [42, 31])

    rest
    |> Enum.map(fn {:rule, n, r} -> {:rule, n, replace_rule(r, num, rule)} end)
    |> process_rules2()
  end

  defp process_rules2([{:rule, num, rule} | rest]) do
    rest
    |> Enum.map(fn {:rule, n, r} -> {:rule, n, replace_rule(r, num, rule)} end)
    |> process_rules2()
  end
end
