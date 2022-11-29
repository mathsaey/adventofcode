import AOC

aoc 2021, 12 do
  @ascii_upper ?A..?Z
  @ascii_lower ?a..?z

  def parse(stream) do
    stream
    |> Stream.flat_map(fn str ->
      [l, r] = String.split(str, "-")
      l = parse_cave(l)
      r = parse_cave(r)
      [{l, r}, {r, l}]
    end)
    |> Stream.reject(fn {l, r} -> r == :start or l == :end end)
    |> Stream.map(fn
      {{_, c}, r} -> {c, r}
      {l, r} -> {l, r}
    end)
    |> Enum.reduce(%{}, fn {from, to}, map -> Map.update(map, from, [to], &[to | &1]) end)
  end

  def parse_cave("start"), do: :start
  def parse_cave("end"), do: :end

  def parse_cave(s = <<c, _::binary>>) when c in @ascii_upper, do: {:large, String.to_atom(s)}
  def parse_cave(s = <<c, _::binary>>) when c in @ascii_lower, do: {:small, String.to_atom(s)}

  def all_paths(map, visited?), do: all_paths(map[:start], map, MapSet.new(), visited?, [:start])

  def all_paths([], _, _, _, _), do: []

  def all_paths([:end | tl], map, visited, visited?, path) do
    [Enum.reverse([:end | path])] ++ all_paths(tl, map, visited, visited?, path)
  end

  def all_paths([{type, c} | tl], map, visited, visited?, path) do
    cond do
      type == :small and c in visited ->
        all_paths(tl, map, visited, visited?, path)
      type == :small and not visited? ->
        all_paths(map[c], map, visited, true, [c | path])
        ++ all_paths(map[c], map, MapSet.put(visited, c), false, [c | path])
        ++ all_paths(tl, map, visited, visited?, path)
      true ->
        all_paths(
          map[c],
          map,
          if(type == :small, do: MapSet.put(visited, c), else: visited),
          visited?,
          [c | path]
        ) ++ all_paths(tl, map, visited, visited?, path)
    end
  end

  def p1, do: input_stream() |> parse() |> all_paths(true) |> length()
  def p2, do: input_stream() |> parse() |> all_paths(false) |> Enum.uniq() |> length()
end
