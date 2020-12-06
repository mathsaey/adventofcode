import AOC

aoc 2020, 6 do
  def p1, do: solve(&MapSet.union/2)
  def p2, do: solve(&MapSet.intersection/2)

  def solve(joiner) do
    input_string()
    |> String.split("\n\n")
    |> Enum.map(&group(&1, joiner))
    |> Enum.map(&Enum.count/1)
    |> Enum.sum()
  end

  def group(str, joiner) do
    str
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(joiner)
  end
end
