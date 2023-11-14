import AOC

aoc 2021, 18 do
  def p1, do: input_stream() |> parse() |> Enum.reduce(&add(&2, &1)) |> magnitude()

  def p2 do
    input_stream()
    |> parse()
    |> pairs()
    |> Stream.map(fn {l, r} -> add(l, r) |> magnitude() end)
    |> Enum.max()
  end

  def pairs(stream), do: for(i <- stream, j <- stream, i != j, do: {i, j})

  def parse(stream), do: stream |> Stream.map(&parse(&1,[]))

  # Code.eval works too, but let's not go there :).
  def parse(<<>>, [stack]), do: stack
  def parse(<<?[, rest::binary>>, stack), do: parse(rest, stack)
  def parse(<<?,, rest::binary>>, stack), do: parse(rest, stack)
  def parse(<<?], rest::binary>>, [s1, s2 | tl]), do: parse(rest, [[s2, s1] | tl])
  def parse(<<x, rest::binary>>, stack) when x in ?0..?9, do: parse(rest, [x - ?0 | stack])

  def add(l, r), do: reduce([l, r])

  def reduce(term) do
    with term when is_list(term) <- explode(term, 0),
         term when is_list(term) <- split(term) do
      term
    else
      {:split, term} -> reduce(term)
      {:explode, term, _, _} -> reduce(term)
    end
  end

  def split(n) when is_number(n) and n >= 10, do: {:split, [div(n, 2), trunc(Float.ceil(n / 2))]}
  def split(n) when is_number(n), do: n

  def split([l, r]) do
    with {:l, l} when not is_tuple(l) <- {:l, split(l)},
         {:r, r} when not is_tuple(r) <- {:r, split(r)} do
      [l, r]
    else
      {:l, {:split, l}} -> {:split, [l, r]}
      {:r, {:split, r}} -> {:split, [l, r]}
    end
  end

  def explode([l, r], d) when is_number(l) and is_number(r) and d >= 4, do: {:explode, 0, l, r}
  def explode(n, _) when is_number(n), do: n

  def explode([l, r], d) do
    with {:l, l} when not is_tuple(l) <- {:l, explode(l, d + 1)},
         {:r, r} when not is_tuple(r) <- {:r, explode(r, d + 1)} do
      [l, r]
    else
      {:l, {:explode, l, add_l, add_r}} ->
        {r, add_r} = propagate(r, add_r, :l)
        {:explode, [l, r], add_l, add_r}
      {:r, {:explode, r, add_l, add_r}} ->
        {l, add_l} = propagate(l, add_l, :r)
        {:explode, [l, r], add_l, add_r}
    end
  end

  def propagate(any, nil, _), do: {any, nil}
  def propagate(n, add, _) when is_number(n), do: {n + add, nil}

  def propagate([l, r], add, :l) do
    {l, add} = propagate(l, add, :l)
    {[l, r], add}
  end

  def propagate([l, r], add, :r) do
    {r, add} = propagate(r, add, :r)
    {[l, r], add}
  end

  def magnitude([l, r]), do: 3 * magnitude(l) + 2 * magnitude(r)
  def magnitude(n), do: n
end
