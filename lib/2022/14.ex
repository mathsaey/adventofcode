import AOC

aoc 2022, 14 do
  @source {500, 0}

  def p1(input), do: input |> solve(&drop_p1/2)
  def p2(input), do: input |> solve(&drop_p2/2)

  def solve(input, drop) do
    input |> parse() |> drop_until(drop) |> Enum.count(fn {_, v} -> v == :sand end)
  end

  def drop_until(map, drop) do
    case drop.(@source, map) do
      {:ok, map} -> drop_until(map, drop)
      {:done, map} -> map
    end
  end

  def drop_p1({_, y}, map = %{max: max_y}) when y > max_y, do: {:done, map}

  def drop_p1({x, y}, map) do
    cond do
      !map[{x, y + 1}] -> drop_p1({x, y + 1}, map)
      !map[{x - 1, y + 1}] -> drop_p1({x - 1, y + 1}, map)
      !map[{x + 1, y + 1}] -> drop_p1({x + 1, y + 1}, map)
      true -> {:ok, Map.put(map, {x, y}, :sand)}
    end
  end

  def drop_p2({x, y}, map) do
    cond do
      map[@source] -> {:done, map}
      y + 1 > map[:max] + 1 -> {:ok, Map.put(map, {x, y}, :sand)}
      !map[{x, y + 1}] -> drop_p2({x, y + 1}, map)
      !map[{x - 1, y + 1}] -> drop_p2({x - 1, y + 1}, map)
      !map[{x + 1, y + 1}] -> drop_p2({x + 1, y + 1}, map)
      true -> {:ok, Map.put(map, {x, y}, :sand)}
    end
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.flat_map(&parse_line/1)
    |> Map.new()
    |> add_lower_bounds()
  end

  def parse_line(line) do
    line
    |> String.split(" -> ")
    |> Enum.map(fn coord ->
      coord |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    end)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.flat_map(&expand/1)
    |> Enum.map(&{&1, :rock})
  end

  def expand([{x, fy}, {x, ty}]), do: for(y <- fy..ty, do: {x, y})
  def expand([{fx, y}, {tx, y}]), do: for(x <- fx..tx, do: {x, y})

  def add_lower_bounds(map) do
    y = map |> Enum.max_by(fn {{_, y}, _} -> y end) |> then(fn {{_, y}, _} -> y end)
    Map.put(map, :max, y)
  end
end
