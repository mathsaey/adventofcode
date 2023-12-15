import AOC

aoc 2023, 15 do
  def p1(input), do: input |> parse() |> Enum.map(&hash/1) |> Enum.sum()

  def p2(input) do
    input
    |> parse()
    |> Enum.map(&read/1)
    |> Enum.reduce(%{}, &exec/2)
    |> Enum.flat_map(fn {box, lenses} ->
      lenses |> Enum.with_index(1) |> Enum.map(fn {{_, lens}, idx} -> (box + 1) * idx * lens end)
    end)
    |> Enum.sum()
  end

  def exec({:del, box, label}, boxes) do
    Map.update(boxes, box, [], &List.keydelete(&1, label, 0))
  end

  def exec({:add, box, label, lens}, boxes) do
    Map.update(boxes, box, [{label, lens}], &List.keystore(&1, label, 0, {label, lens}))
  end

  def read(str) do
    case String.split(str, ["-", "="]) do
      [pre, <<>>] -> {:del, hash(pre), pre}
      [pre, <<n>>] -> {:add, hash(pre), pre, n - ?0}
    end
  end

  def hash(str), do: hash(str, 0)
  def hash(<<>>, res), do: res
  def hash(<<c, rest::binary>>, res), do: hash(rest, rem((c + res) * 17, 256))

  def parse(input), do: String.split(input, ",")
end
