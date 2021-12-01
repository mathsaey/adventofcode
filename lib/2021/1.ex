import AOC

aoc 2021, 1 do
  def input_stream, do: super() |> Stream.map(&String.to_integer/1)
  def p1, do: input_stream() |> count_increasing()

  def p2 do
    input_stream()
    |> Stream.chunk_every(3, 1, :discard)
    |> Enum.to_list()
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
