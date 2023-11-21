import AOC

aoc 2021, 9 do
  def p1(input) do
    input |> parse() |> low_points() |> Stream.map(fn {_, h} -> h + 1 end) |> Enum.sum()
  end

  def p2(input) do
    map = parse(input)
    low_points = map |> low_points() |> Enum.map(fn {c, _} -> {c, c} end) |> Map.new()

    map
    |> Enum.reduce(low_points, &update_basins(&1, &2, map))
    |> Map.values()
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.reduce(1, &(&1 * &2))
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {str, y} ->
      str
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.map(fn {el, x} -> {{x, y}, el} end)
    end)
    |> Map.new()
  end

  def adjacent_coords({x, y}), do: [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
  def adjacent({x, y}, m), do: {x, y} |> adjacent_coords() |> Enum.map(&{&1, Map.get(m, &1, 10)})

  def low_points(map) do
    map
    |> Stream.map(fn {coord, height} -> {coord, height, adjacent(coord, map)} end)
    |> Stream.map(fn {coord, height, adj} -> {coord, height, Enum.map(adj, &elem(&1, 1))} end)
    |> Stream.filter(fn {_, height, adj} -> height < Enum.min(adj) end)
    |> Stream.map(fn {coord, height, _} -> {coord, height} end)
  end

  def update_basins({_, 9}, basins, _), do: basins
  def update_basins(tup, basins, map), do: elem(do_update_basins(tup, basins, map), 0)

  def do_update_basins({c, _}, basins, _) when is_map_key(basins, c), do: {basins, basins[c]}

  def do_update_basins({coord, _}, basins, map) do
    {basins, low_point} =
      coord
      |> adjacent(map)
      |> Enum.min_by(&elem(&1, 1))
      |> do_update_basins(basins, map)

    {Map.put(basins, coord, low_point), low_point}
  end
end
