import AOC

aoc 2021, 5 do
  def p1 do
    input_stream()
    |> parse()
    |> Stream.filter(fn {{x1, y1}, {x2, y2}} -> x1 == x2 or y1 == y2 end)
    |> count_overlaps()
  end

  def p2, do: input_stream() |> parse() |> count_overlaps()

  def parse(stream) do
    Stream.map(stream, fn line ->
      [x1, y1, x2, y2] =
        line
        |> String.split(" -> ")
        |> Enum.flat_map(&String.split(&1, ","))
        |> Enum.map(&String.to_integer/1)

      {{x1, y1}, {x2, y2}}
    end)
  end

  def expand({{x1, y1}, {x2, y2}}) when x1 == x2 or y1 == y2 do
    for x <- x1..x2, y <- y1..y2, do: {x, y}
  end

  def expand({{x1, y1}, {x2, y2}}), do: Enum.zip(x1..x2, y1..y2)

  def count_overlaps(stream) do
    stream
    |> Stream.map(&expand/1)
    |> Stream.flat_map(&(&1))
    |> Enum.frequencies()
    |> Enum.filter(fn {_, amount} -> amount >= 2  end)
    |> Enum.count()
  end
end
