import AOC

aoc 2022, 12 do
  def p1(input), do: solve(input, fn dists, _, src -> Map.put(dists, src, 0) end)

  def p2(input) do
    solve(input, fn dists, heights, _ ->
      heights
      |> Enum.filter(fn {_, h} -> h == 0 end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.reduce(dists, &Map.put(&2, &1, 0))
    end)
  end

  def solve(input, transform_distances) do
    {src, dst, heights} = parse(input)

    heights
    |> Map.keys()
    |> Map.new(&{&1, :infinity})
    |> transform_distances.(heights, src)
    |> dijkstra(heights, dst)
  end

  def dijkstra(dists, heights, dst) do
    case Enum.min_by(dists, &elem(&1, 1)) do
      {^dst, dist} ->
        dist
      {cur, dist} ->
        cur
        |> neighbours(heights)
        |> Enum.reduce(dists, fn n, dists -> Map.replace_lazy(dists, n, &min(&1, dist + 1)) end)
        |> Map.delete(cur)
        |> dijkstra(heights, dst)
    end
  end

  def neighbours({x, y}, heights) do
    h = heights[{x, y}]
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}] |> Enum.filter(&(heights[&1] <= h + 1))
  end

  def parse(input) do
    grid =
      input
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.codepoints/1)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row |> Enum.with_index() |> Enum.map(fn {el, x} -> {{x, y}, el} end)
      end)

    src = grid |> Enum.find(grid, fn {_, v} -> v == "S" end) |> elem(0)
    dst = grid |> Enum.find(grid, fn {_, v} -> v == "E" end) |> elem(0)
    heights = grid |> Enum.map(fn {k, v} -> {k, elevation(v)} end) |> Map.new()
    {src, dst, heights}
  end

  def elevation("S"), do: elevation("a")
  def elevation("E"), do: elevation("z")
  def elevation(<<c>>), do: c - ?a
end
