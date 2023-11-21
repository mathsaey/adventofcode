import AOC

aoc 2021, 1 do
  def parse(input), do: input |> String.split("\n") |> Enum.map(&String.to_integer/1)
  def p1(input), do: input |> parse() |> count_increasing()

  def p2(input) do
    input
    |> parse()
    |> Stream.chunk_every(3, 1, :discard)
    |> Stream.map(&Enum.sum/1)
    |> count_increasing()
  end

  def count_increasing(enum) do
    enum
    |> Enum.reduce({0, -1}, fn el, {prev, ctr} ->
      if el > prev, do: {el, ctr + 1}, else: {el, ctr}
    end)
    |> elem(1)
  end
end
