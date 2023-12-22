import AOC

aoc 2023, 21 do
  def p1(input), do: input |> parse() |> rocks_stream() |> Enum.at(64)

  def p2(input) do
    {start, rocks, size} = input |> parse() |> add_negative_rocks()
    rocks = rocks_stream({start, rocks, size})

    Stream.iterate(0, &(&1 + 1))
    |> Stream.map(&{&1, (div(size, 2) + &1 * size)})
    |> Stream.map(fn {idx, steps} -> {idx, Enum.at(rocks, steps)} end)
    |> Enum.take(3)
    |> then(fn tups -> apply(&lagrange/3, tups) end)
    |> apply([202300])
  end

  def lagrange({x0, y0}, {x1, y1}, {x2, y2}) do
    fn x ->
      t0 = div((x - x1) * (x - x2), (x0 - x1) * (x0 - x2)) * y0
      t1 = div((x - x0) * (x - x2), (x1 - x0) * (x1 - x2)) * y1
      t2 = div((x - x0) * (x - x1), (x2 - x0) * (x2 - x1)) * y2
      t0 + t1 + t2
    end
  end

  def rocks_stream({start, rocks, size}) do
    [start]
    |> Stream.iterate(&next(&1, rocks, size))
    |> Stream.map(&length/1)
  end

  def next(positions, rocks, size) do
    positions
    |> Enum.flat_map(&neighbours(&1, rocks, size))
    |> Enum.uniq()
  end

  def neighbours({x, y}, rocks, size) do
    [{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]
    |> Enum.reject(fn {x, y} -> {rem(x, size), rem(y, size)} in rocks end)
  end

  def add_negative_rocks({start, rocks, size}) do
    rocks
    |> Enum.flat_map(fn {x, y} -> [{x - size, y - size}, {x - size, y}, {x, y - size}] end)
    |> Enum.concat(rocks)
    |> MapSet.new()
    |> then(fn rocks -> {start, rocks, size} end)
  end

  def parse(input) do
    {grid, {xrange, _}} = Utils.Grid.input_to_map_with_bounds(input)
    {start, _} = Enum.find(grid, fn {_, v} -> v == "S" end)
    rocks = grid |> Enum.filter(fn {_, v} -> v == "#" end) |> MapSet.new(&elem(&1, 0))
    {start, rocks, Range.size(xrange)}
  end
end
