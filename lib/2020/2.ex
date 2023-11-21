import AOC

aoc 2020, 2 do
  def p1(input), do: solve(input, &verify_p1/1)
  def p2(input), do: solve(input, &verify_p2/1)

  defp solve(input, verify) do
    input
    |> String.split("\n")
    |> Enum.map(&parse/1)
    |> Enum.filter(verify)
    |> Enum.count()
  end

  defp parse(str) do
    [_, x, y, c, str] = Regex.run(~r/(\d+)-(\d+) (.)+: (.+)/, str)
    {String.to_integer(x), String.to_integer(y), c, str}
  end

  defp verify_p1({min, max, c, str}) do
    count = str |> String.codepoints() |> Enum.count(&(&1 == c))
    min <= count and count <= max
  end

  defp verify_p2({p1, p2, c, str}) do
    c1 = String.at(str, p1 - 1) == c
    c2 = String.at(str, p2 - 1) == c
    (c1 or c2) and not (c1 and c2)
  end
end
