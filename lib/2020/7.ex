import AOC

aoc 2020, 7 do
  def p1 do
    root = parent(input_string())

    root
    |> Map.keys()
    |> Enum.map(&contains(&1, root))
    |> Enum.filter(&("shiny gold" in &1))
    |> Enum.count()
  end

  def p2 do
    root = parent(input_string())
    count(root["shiny gold"], root) - 1
  end

  def parse(input, split, regex, mapper) do
    input
    |> String.trim()
    |> String.split(split)
    |> Enum.map(&Regex.run(regex, &1, capture: :all_but_first))
    |> Enum.map(mapper)
    |> Map.new()
  end

  @parent ~r/^(\w+ \w+) bags contain( no other bags.|(?> \d \w+ \w+ bags?(?>\.|,))+)/
  def parent(str), do: parse(str, "\n", @parent, fn [hd, tl] -> {hd, parse_children(tl)} end)

  @children ~r/ ?(\d) (\w+ \w+) bags?.?/
  defp parse_children(" no other bags."), do: %{}
  defp parse_children(s), do: parse(s, ",", @children, fn [i, n] -> {n, String.to_integer(i)} end)

  def contains(bag, map) do
    map[bag]
    |> Map.keys()
    |> Enum.reduce(MapSet.new(), &MapSet.union(&2, MapSet.put(contains(&1, map), &1)))
  end

  def count(map, _) when map_size(map) == 0, do: 1

  def count(children, root) do
    Enum.reduce(children, 1, fn {name, amount}, acc -> acc + amount * count(root[name], root) end)
  end
end
