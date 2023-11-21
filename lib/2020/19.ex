import AOC

aoc 2020, 19 do
  def p1(input) do
    {rules, input} = parse(input)
    input |> Enum.filter(&check(&1, Map.get(rules, 0), rules)) |> Enum.count()
  end

  def p2(input) do
    {rules, input} = parse(input)
    rules = rules |> Map.put(8, {[42], [42, 8]}) |> Map.put(11, {[42, 31], [42, 11, 31]})

    input |> Enum.filter(&check(&1, Map.get(rules, 0), rules)) |> Enum.count()
  end

  def check("", [], _), do: true
  def check(str, [hd | tl], m) when is_integer(hd), do: check(str, get(m, hd) ++ tl, m)
  def check(<<el, r::binary>>, [<<el>> | tl], m), do: check(r, tl, m)
  def check(str, [{l, r} | tl], m), do: check(str, l ++ tl, m) or check(str, r ++ tl, m)
  def check(_, _, _), do: false

  def get(rules, id) do
    case Map.get(rules, id) do
      s when is_binary(s) -> [s]
      {l, r} -> [{l, r}]
      other -> other
    end
  end

  def parse(input) do
    [rules, input] = input |> String.split("\n\n") |> Enum.map(&String.trim/1)
    {parse_rules(rules), String.split(input, "\n")}
  end

  def parse_rules(rules) do
    rules
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ":"))
    |> Enum.map(fn [k, v] -> {String.to_integer(k), v |> String.trim() |> parse_rule()} end)
    |> Map.new()
  end

  def parse_rule(<<?", c, ?">>), do: <<c>>

  def parse_rule(composite) do
    composite
    |> String.split("|")
    |> Enum.map(fn str ->
      str |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    end)
    |> case do
      [rule] -> rule
      [left, right] -> {left, right}
    end
  end
end
