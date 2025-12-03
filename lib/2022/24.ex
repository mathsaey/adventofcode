import AOC

aoc 2022, 24 do
  def p1(input) do
    map = parse(input)
    {_, _, start, stop} = bounds(map)
    find_path(map, 1, start, stop)
  end

  def p2(input) do
    map = parse(input)
    {_, _, start, stop} = bounds(map)
    there = find_path(map, 1, start, stop)
    back = find_path(map, there, stop, start)
    again = find_path(map, back, start, stop)
    again
  end

  def find_path(map, step, from, to) do
    bounds = bounds(map)
    blizzards = precompute_blizzards(map, bounds)
    find_path(MapSet.new([from]), step, to, blizzards, bounds)
  end

  def find_path(positions, step, goal, blizzards, bounds) do
    if goal in positions do
      step
    else
      positions
      |> Enum.flat_map(&moves(&1, bounds))
      |> Enum.reject(&(&1 in blizzards_at(blizzards, step + 1)))
      |> MapSet.new()
      |> find_path(step + 1, goal, blizzards, bounds)
    end
  end

  def moves({x, y}, {xrange, yrange, start, stop}) do
    [{x, y}, {x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
    |> Enum.filter(fn c = {x, y} -> (x in xrange and y in yrange) or c == start or c == stop end)
  end

  def blizzards_at(blizzards, step), do: elem(blizzards, rem(step, tuple_size(blizzards)))

  def precompute_blizzards(map, bounds) do
    period = period(bounds)

    map
    |> Enum.group_by(&elem(&1, 1))
    |> Enum.filter(&(elem(&1, 0) in [:up, :down, :left, :right]))
    |> Enum.flat_map(&elem(&1, 1))
    |> Stream.iterate(&Enum.map(&1, fn {c, d} -> {next(c, d, bounds), d} end))
    |> Stream.map(&MapSet.new(&1, fn {c, _} -> c end))
    |> Enum.take(period)
    |> List.to_tuple()
  end

  def next({x, y}, :down, {_, b = m.._//_, _, _}), do: if(y + 1 in b, do: {x, y + 1}, else: {x, m})
  def next({x, y}, :up, {_, b = _..m//_, _, _}), do: if(y - 1 in b, do: {x, y - 1}, else: {x, m})
  def next({x, y}, :left, {b = _..m//_, _, _, _}), do: if(x - 1 in b, do: {x - 1, y}, else: {m, y})
  def next({x, y}, :right, {b = m.._//_, _, _, _}), do: if(x + 1 in b, do: {x + 1, y}, else: {m, y})

  def bounds(map) do
    {max_x, max_y} = map |> Map.keys() |> Enum.max()
    {1..(max_x - 1), 1..(max_y - 1), {1, 0}, {max_x - 1, max_y}}
  end

  def period({_..max_x//_, _..max_y//_, _, _}), do: Utils.lcd(max_x, max_y)

  @symbols %{"#" => :wall, "^" => :up, "v" => :down, "<" => :left, ">" => :right}
  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.codepoints()
      |> Enum.map(&@symbols[&1])
      |> Enum.with_index()
      |> Enum.map(fn {v, x} -> {{x, y}, v} end)
    end)
    |> Map.new()
  end
end
