import AOC

aoc 2023, 9 do
  def p1(input), do: input |> parse() |> solve()
  def p2(input), do: input |> parse() |> Enum.map(&Enum.reverse/1) |> solve()
  def solve(lsts), do: lsts |> Enum.map(&get_next/1) |> Enum.sum()

  def get_next(lst) do
    lst
    |> Stream.iterate(&difference/1)
    |> Enum.take_while(fn lst -> Enum.any?(lst, &(&1 != 0)) end)
    |> Enum.map(&List.last/1)
    |> Enum.sum()
  end

  def difference(lst) do
    lst |> Enum.chunk_every(2,1, :discard) |> Enum.map(fn [cur, next] -> next - cur end)
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line -> line |> String.split() |> Enum.map(&String.to_integer/1) end)
  end
end
