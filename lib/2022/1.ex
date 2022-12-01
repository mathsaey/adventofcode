import AOC

aoc 2022, 1 do
  def p1(input), do: input |> parse() |> Enum.max()
  def p2(input), do: input |> parse() |> Enum.sort(:desc) |> Enum.take(3) |> Enum.sum()

  def parse(string) do
    string
    |> String.split("\n")
    |> Stream.chunk_by(&(&1 != ""))
    |> Stream.reject(&(&1 == [""]))
    |> Stream.map(fn lst -> Enum.map(lst, &String.to_integer/1) end)
    |> Stream.map(&Enum.sum/1)
  end
end
