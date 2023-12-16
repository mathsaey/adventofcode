import AOC

aoc 2023, 16 do
  def p1(input), do: input |> parse() |> follow({:east, {0, 0}}) |> count()
  def p2(input), do: input |> parse() |> follow_all() |> Enum.map(&count/1) |> Enum.max()

  def count(set), do: set |> Enum.map(fn {_, pos} -> pos end) |> Enum.uniq() |> length()

  def follow_all(grid) do
    grid
    |> all_starts()
    |> Task.async_stream(&follow(grid, &1))
    |> Enum.map(fn {:ok, res} -> res end)
  end

  def all_starts({_, xrange = min_x..max_x, yrange = min_y..max_y}) do
    Enum.concat(
      Enum.flat_map(xrange, fn x -> [{:north, {x, max_y}}, {:south, {x, min_y}}] end),
      Enum.flat_map(yrange, fn y -> [{:west, {max_x, y}}, {:east, {min_x, y}}] end)
    )
  end

  def follow(grid, start), do: follow(MapSet.new([start]), [start], grid)

  def follow(seen, beams, grid_with_bounds = {grid, min_x..max_x, min_y..max_y}) do
    beams
    |> Enum.flat_map(fn t = {_, pos} -> next(t, grid[pos]) end)
    |> Enum.reject(fn {_, {x, y}} -> x < min_x or x > max_x or y < min_y or y > max_y end)
    |> Enum.reject(&(&1 in seen))
    |> case do
      [] -> seen
      beams -> beams |> Enum.reduce(seen, &MapSet.put(&2, &1)) |> follow(beams, grid_with_bounds)
    end
  end

  def next({:north, {x, y}}, nil), do: [{:north, {x, y - 1}}]
  def next({:south, {x, y}}, nil), do: [{:south, {x, y + 1}}]
  def next({:east, {x, y}}, nil), do: [{:east, {x + 1, y}}]
  def next({:west, {x, y}}, nil), do: [{:west, {x - 1, y}}]

  def next({:north, pos}, :lrmirror), do: next({:west, pos}, nil)
  def next({:south, pos}, :lrmirror), do: next({:east, pos}, nil)
  def next({:east, pos}, :lrmirror), do: next({:south, pos}, nil)
  def next({:west, pos}, :lrmirror), do: next({:north, pos}, nil)
  def next({:north, pos}, :rlmirror), do: next({:east, pos}, nil)
  def next({:south, pos}, :rlmirror), do: next({:west, pos}, nil)
  def next({:east, pos}, :rlmirror), do: next({:north, pos}, nil)
  def next({:west, pos}, :rlmirror), do: next({:south, pos}, nil)

  def next(t = {dir, _}, :hsplit) when dir in [:east, :west], do: next(t, nil)
  def next(t = {dir, _}, :vsplit) when dir in [:north, :south], do: next(t, nil)

  def next({_, pos}, :hsplit), do: next({:east, pos}, nil) ++ next({:west, pos}, nil)
  def next({_, pos}, :vsplit), do: next({:north, pos}, nil) ++ next({:south, pos}, nil)

  @mappings %{?| => :vsplit, ?- => :hsplit, ?\\ => :lrmirror, ?/ => :rlmirror}

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {<<c>>, x} -> {{x, y}, @mappings[c]} end)
    end)
    |> Map.new()
    |> with_bounds()
  end

  def with_bounds(grid) do
    {min_x, max_x} = grid |> Map.keys() |> Enum.map(fn {x, _} -> x end) |> Enum.min_max()
    {min_y, max_y} = grid |> Map.keys() |> Enum.map(fn {_, y} -> y end) |> Enum.min_max()
    {grid |> Enum.reject(fn {_, el} -> el == nil end) |> Map.new(), min_x..max_x, min_y..max_y}
  end
end
