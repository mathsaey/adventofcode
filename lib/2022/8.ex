import AOC

aoc 2022, 8 do
  def p1(input), do: input |> parse() |> add_max() |> Enum.count(fn {_, el} -> visible?(el) end)

  def p2(input) do
    grid = parse(input)
    grid |> Map.keys() |> Enum.map(&score(&1, grid)) |> Enum.max()
  end

  def score(coord, grid) do
    t = view_distance(coord, grid, fn {x, y} -> {x, y - 1} end)
    l = view_distance(coord, grid, fn {x, y} -> {x - 1, y} end)
    b = view_distance(coord, grid, fn {x, y} -> {x, y + 1} end)
    r = view_distance(coord, grid, fn {x, y} -> {x + 1, y} end)
    l * r * t * b
  end

  def view_distance(coord, grid, next) do
    height = grid[coord][:height]

    next.(coord)
    |> Stream.iterate(next)
    |> Stream.with_index(1)
    |> Stream.drop_while(fn {c, _} -> grid[c][:height] < height end)
    |> Enum.take(1)
    |> then(fn [{c, d}] -> if grid[c], do: d , else: d - 1 end)
  end

  def visible?(el) do
    el.height > el.left or el.height > el.right or el.height > el.top or el.height > el.bottom
  end

  def add_max(grid) do
    grid
    |> add_max_in_direction(&elem(&1, 0), :asc, fn {x, y} -> {x - 1, y} end, :left)
    |> add_max_in_direction(&elem(&1, 0), :desc, fn {x, y} -> {x + 1, y} end, :right)
    |> add_max_in_direction(&elem(&1, 1), :asc, fn {x, y} -> {x, y - 1} end, :top)
    |> add_max_in_direction(&elem(&1, 1), :desc, fn {x, y} -> {x, y + 1} end, :bottom)
  end

  def add_max_in_direction(grid, sort_key_by, key_sort_order, prev_key_fun, direction) do
    ordered_keys = grid |> Map.keys() |> Enum.sort_by(sort_key_by, key_sort_order)

    Enum.reduce(ordered_keys, grid, fn key, grid ->
      prev = grid[prev_key_fun.(key)]
      prev_max = max(prev[:height], prev[direction]) || -1
      Map.update!(grid, key, &Map.put(&1, direction, prev_max))
    end)
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn row ->
      row |> String.codepoints() |> Enum.map(&String.to_integer/1) |> Enum.with_index()
    end)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} -> Enum.map(row, fn {el, x} -> {{x, y}, %{height: el}} end) end)
    |> Map.new()
  end
end
