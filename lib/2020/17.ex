import AOC

aoc 2020, 17 do
  def p1(input), do: run(input, 3)
  def p2(input), do: run(input, 4)

  def run(input, dimensions) do
    input |> parse() |> dimensions(dimensions) |> turns(6) |> Enum.count()
  end

  def turns(active, 0), do: active
  def turns(active, n), do: active |> turn() |> turns(n - 1)

  def turn(active) do
    active
    |> Enum.flat_map(&neighbours/1)
    |> MapSet.new()
    |> Enum.filter(
      &case {&1 in active, active_neighbours(&1, active)} do
        {true, n} when n == 2 or n == 3 -> true
        {true, _} -> false
        {false, 3} -> true
        {false, _} -> false
      end
    )
    |> MapSet.new()
  end

  def active_neighbours(coord, set), do: coord |> neighbours() |> Enum.count(&(&1 in set))

  def neighbours({x, y, z}) do
    for nx <- (x - 1)..(x + 1),
        ny <- (y - 1)..(y + 1),
        nz <- (z - 1)..(z + 1),
        {x, y, z} != {nx, ny, nz} do
      {nx, ny, nz}
    end
  end

  def neighbours({x, y, z, w}) do
    for nx <- (x - 1)..(x + 1),
        ny <- (y - 1)..(y + 1),
        nz <- (z - 1)..(z + 1),
        nw <- (w - 1)..(w + 1),
        {x, y, z, w} != {nx, ny, nz, nw} do
      {nx, ny, nz, nw}
    end
  end

  def dimensions(lst, n) when is_list(lst), do: Enum.map(lst, &dimensions(&1, n))
  def dimensions({x, y}, 3), do: {x, y, 0}
  def dimensions({x, y}, 4), do: {x, y, 0, 0}

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Enum.with_index()
    |> Enum.reduce([], &parse_row/2)
  end

  def parse_row({row, y}, lst) do
    row
    |> Enum.with_index()
    |> Enum.reduce(lst, fn
      {"#", x}, lst -> [{x, y} | lst]
      _, lst -> lst
    end)
  end
end
