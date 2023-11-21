import AOC

aoc 2020, 4 do
  def p1(input), do: solve(input, &verify_p1?/1)
  def p2(input), do: solve(input, &verify_p2?/1)

  defp solve(input,verify), do: input |> parse() |> Enum.filter(verify) |> Enum.count()
  defp parse(input), do: input |> String.split("\n\n") |> Enum.map(&parse_inner/1)

  defp parse_inner(entry) do
    entry
    |> String.split()
    |> Enum.map(&String.split(&1, ":"))
    |> Enum.map(fn [k, v] -> {String.to_atom(k), v} end)
    |> Map.new()
  end

  defp verify_p1?(map) do
    required = MapSet.new([:byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid])
    fields = map |> Map.keys() |> MapSet.new()
    MapSet.difference(required, fields) |> MapSet.to_list() == []
  end

  def verify_p2?(map) do
    height? =
      case map[:hgt] do
        <<str::binary-size(3), "cm">> -> between?(str, 150, 193)
        <<str::binary-size(2), "in">> -> between?(str, 59, 76)
        _ -> false
      end

    height? and
      between?(map[:byr], 1920, 2002) and
      between?(map[:iyr], 2010, 2020) and
      between?(map[:eyr], 2020, 2030) and
      Regex.match?(~r/#[a-z0-9]{6}/, map[:hcl] || "") and
      Regex.match?(~r/^\d{9}$/, map[:pid] || "") and
      map[:ecl] in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
  end

  defp between?(nil, _, _), do: false
  defp between?(n, l, r) when is_binary(n), do: between?(String.to_integer(n), l, r)
  defp between?(n, l, r), do: n >= l and n <= r
end
