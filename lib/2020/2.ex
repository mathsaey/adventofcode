import AOC

aoc 2020, 2 do
  def p1, do: solve(&verify_p1/1)
  def p2, do: solve(&verify_p2/1)

  defp solve(verify) do
    input_stream()
    |> Stream.map(&parse/1)
    |> Stream.filter(verify)
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
