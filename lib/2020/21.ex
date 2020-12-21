import AOC

aoc 2020, 21 do
  def p1 do
    forbidden = allergen_ingredients() |> Map.values() |> Enum.reduce(&MapSet.union/2)
    parse() |> Stream.map(&elem(&1, 0)) |> Stream.concat() |> Enum.count(&(&1 not in forbidden))
  end

  def p2 do
    allergen_ingredients()
    |> eliminate()
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(fn {_, s} -> s |> MapSet.to_list() |> hd() end)
    |> Enum.join(",")
  end

  def allergen_ingredients do
    parse()
    |> Stream.map(&candidates/1)
    |> Enum.reduce(&merge/2)
  end

  def eliminate(map, eliminated \\ MapSet.new()) do
    {lst, eliminated} =
      Enum.map_reduce(map, eliminated, fn {k, options}, eliminated ->
        if MapSet.size(options) == 1 do
          {{k, options}, MapSet.union(eliminated, options)}
        else
          {{k, MapSet.difference(options, eliminated)}, eliminated}
        end
      end)

    if Enum.all?(lst, fn {_, v} -> MapSet.size(v) == 1 end) do
      Map.new(lst)
    else
      eliminate(lst, eliminated)
    end
  end

  def merge(c1, c2), do: Map.merge(c1, c2, fn _, s1, s2 -> MapSet.intersection(s1, s2) end)

  def candidates({ingredients, allergens}) do
    for allergen <- allergens, into: %{}, do: {allergen, MapSet.new(ingredients)}
  end

  def parse, do: input_stream() |> Stream.map(&parse_line/1)

  def parse_line(str) do
    [_, ingredients, allergens] = Regex.run(~r/(.+) \(contains (.+)\)/, str)
    {String.split(ingredients, " "), String.split(allergens, ", ")}
  end
end
