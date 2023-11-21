import AOC

aoc 2021, 14 do
  def p1(input), do: solve(input, 10)
  def p2(input), do: solve(input, 40)

  def solve(input, n), do: input |> parse() |> step_n_times(n) |> count()

  def parse(string) do
    [template, rules] = String.split(string, "\n\n")
    {parse_template(template), parse_rules(rules)}
  end

  def parse_template(string) do
    string |> String.to_charlist() |> Enum.chunk_every(2, 1) |> Enum.frequencies()
  end

  def parse_rules(string) do
    string |> String.trim() |> String.split("\n") |> Enum.map(&parse_rule/1) |> Map.new()
  end

  def parse_rule(string) do
    [cl, [c]] = string |> String.split(" -> ") |> Enum.map(&String.to_charlist/1)
    {cl, c}
  end

  def step(pairs, rules) do
    pairs
    |> Enum.flat_map(fn
      {pair = [l, r], count} ->
        c = rules[pair]
        [{[l, c], count}, {[c, r], count}]
      {pair, count} ->
        [{pair, count}]
    end)
    |> Enum.reduce(%{}, fn {pair, count}, map -> Map.update(map, pair, count, &(&1 + count)) end)
  end

  def step_n_times({pairs, rules}, n), do: step_n_times(pairs, rules, n)
  def step_n_times(pairs, _, 0), do: pairs
  def step_n_times(pairs, rules, n), do: pairs |> step(rules) |> step_n_times(rules, n - 1)

  def count(pairs) do
    pairs
    |> Enum.map(fn {[l | _], count} -> {l, count} end)
    |> Enum.reduce(%{}, fn {el, count}, map -> Map.update(map, el, count, &(&1 + count)) end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.min_max()
    |> then(fn {min, max} -> max - min end)
  end
end
