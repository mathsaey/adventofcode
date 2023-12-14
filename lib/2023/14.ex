import AOC

aoc 2023, 14 do
  def p1(input) do
    {moving, fixed, max_x, max_y} = input |> parse() |> split_and_maxs()
    moving |> cycle_forever(fixed, max_x, max_y) |> Enum.at(1) |> load(max_y)
  end

  def p2(input) do
    {moving, fixed, max_x, max_y} = input |> parse() |> split_and_maxs()
    cycle = cycle_forever(moving, fixed, max_x, max_y)
    {loop_start, loop_size} = find_loop(cycle)
    cycle |> Enum.at(loop_start + rem(1000000000 * 4 - loop_start, loop_size) - 1) |> load(max_y)
  end

  def find_loop(cycle) do
    cycle
    |> Stream.with_index()
    |> Enum.reduce_while([], fn el = {positions, idx}, seen ->
      if found = Enum.find(seen, fn {el, _} -> positions == el end) do
        {_, pos} = found
        {:halt, {pos, idx - pos}}
      else
        {:cont, [el | seen]}
      end
    end)
  end

  def cycle_forever(moving, fixed, max_x, max_y) do
    [
      {fn {x, y} -> {x, y - 1} end, fn {_, yl}, {_, yr} -> yl <= yr end}, # North
      {fn {x, y} -> {x - 1, y} end, fn {xl, _}, {xr, _} -> xl <= xr end}, # West
      {fn {x, y} -> {x, y + 1} end, fn {_, yl}, {_, yr} -> yl >= yr end}, # South
      {fn {x, y} -> {x + 1, y} end, fn {xl, _}, {xr, _} -> xl >= xr end}  # East
    ]
    |> Stream.cycle()
    |> Stream.scan(moving, fn {next_fun, sort_fun}, positions ->
      tilt(positions, fixed, max_x, max_y, next_fun, sort_fun)
    end)
  end

  def load(positions, max_y), do: positions |> Enum.map(fn {_, y} -> max_y - y end) |> Enum.sum()

  def tilt(positions, fixed, max_x, max_y, next_fun, sort_fun) do
    positions
    |> Enum.sort(sort_fun)
    |> Enum.reduce(MapSet.new(), &MapSet.put(&2, roll(&1, &2, fixed, max_x, max_y, next_fun)))
  end

  def roll(pos, moving, fixed, max_x, max_y, next_fun) do
    next = next_fun.(pos)
    {x, y} = next
    if x < 0 or y < 0 or x >= max_x or y >= max_y or next in moving or next in fixed do
      pos
    else
      roll(next, moving, fixed, max_x, max_y, next_fun)
    end
  end

  def split_and_maxs(rocks) do
    {fixed, moving} = Enum.split_with(rocks, fn {_, el} -> el == :fixed end)
    moving = moving |> Enum.map(fn {c, _} -> c end)
    fixed = fixed |> Enum.map(fn {c, _} -> c end) |> MapSet.new()
    max_x = Enum.max_by(fixed, fn {x, _} -> x end) |> elem(0)
    max_y = Enum.max_by(fixed, fn {_, y} -> y end) |> elem(1)
    {moving, fixed, max_x + 1, max_y + 1}
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reject(fn {el, _} -> el == "." end)
      |> Enum.map(fn {el, x} -> {{x, y}, if(el == "O", do: :moving, else: :fixed)} end)
    end)
  end
end
