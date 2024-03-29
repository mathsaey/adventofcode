import AOC

aoc 2020, 3 do
  def p1(input), do: slope(input, 3, 1)

  def p2(input) do
    [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]
    |> Enum.map(fn {right, down} -> slope(input, right, down) end)
    |> Enum.reduce(1, &(&1 * &2))
  end

  def slope(input, right, down) do
    input
    |> String.split("\n")
    |> Stream.map(&String.graphemes/1)
    |> Stream.map(&Stream.cycle/1)
    |> Stream.transform({0, 1}, fn
      stream, {amount, 1} ->
        stream = stream |> Stream.drop(amount) |> Stream.take(1) |> Enum.to_list() |> hd()
        {[stream], {amount + right, down}}

      _, {amount, down} ->
        {[], {amount, down - 1}}
    end)
    |> Enum.count(&(&1 == "#"))
  end
end
