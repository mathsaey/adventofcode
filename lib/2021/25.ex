import AOC

aoc 2021, 25 do
  def p1 do
    input_stream()
    |> parse()
    |> Stream.iterate(&step/1)
    |> Stream.chunk_every(2, 1)
    |> Stream.with_index(1)
    |> Enum.find(fn {[l, r], _} -> l == r end)
    |> elem(1)
  end

  def step(state), do: state |> step(:east) |> step(:south)

  def step({bounds, map}, direction) do
    map
    |> Enum.filter(fn {_, dir} -> dir == direction end)
    |> Enum.reduce(map, fn e = {k, v}, acc ->
      if Map.has_key?(map, next(e, bounds)) do
        acc
      else
        acc |> Map.delete(k) |> Map.put(next(e, bounds), v)
      end
    end)
    |> then(&{bounds, &1})
  end

  def next({{x, y}, :east}, {max_x, _}), do: {rem(x + 1, max_x), y}
  def next({{x, y}, :south}, {_, max_y}), do: {x, rem(y + 1, max_y)}

  def parse(stream) do
    stream
    |> Stream.with_index()
    |> Stream.flat_map(fn {str, y} ->
      str
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.flat_map(fn
        {"v", x} -> [{{x, y}, :south}]
        {">", x} -> [{{x, y}, :east}]
        _ -> []
      end)
    end)
    |> Map.new()
    |> then(&{bounds(stream), &1})
  end

  def bounds(stream) do
    {last, y} = stream |> Stream.with_index() |> Enum.max_by(&elem(&1, 1))
    x = String.length(last) - 1
    {x + 1, y + 1}
  end
end
