import AOC

aoc 2022, 18 do
  def p1(input) do
    set = input |> parse() |> MapSet.new()
    set |> Stream.map(&exposed_sides(&1, set)) |> Enum.sum()
  end

  def p2(input) do
    lava = input |> parse() |> MapSet.new()
    air = find_exterior(lava, bounds(lava))
    lava |> Stream.map(&air_sides(&1, air)) |> Enum.sum()
  end

  def exposed_sides(cube, lava), do: cube |> neighbours() |> Enum.count(&(&1 not in lava))
  def air_sides(cube, air), do: cube |> neighbours() |> Enum.count(&(&1 in air))

  def neighbours({x, y, z}) do
    [{x - 1, y, z}, {x + 1, y, z}, {x, y - 1, z}, {x, y + 1, z}, {x, y, z - 1}, {x, y, z + 1}]
  end

  def find_exterior(lava, bounds) do
    find_exterior({Qex.new([{0, 0, 0}]), MapSet.new([{0,0,0}])}, lava, bounds)
  end

  def find_exterior({queue, air}, lava, bounds) do
    case Qex.pop(queue) do
      {:empty, _} ->
        air

      {{:value, el}, queue} ->
        el
        |> neighbours()
        |> Enum.filter(&in_bounds?(&1, bounds))
        |> Enum.reject(&(&1 in lava || &1 in air))
        |> Enum.reduce({queue, air}, fn el, {q, a} -> {Qex.push(q, el), MapSet.put(a, el)} end)
        |> find_exterior(lava, bounds)
    end
  end

  def in_bounds?({x, y, z}, {{min_x, min_y, min_z}, {max_x, max_y, max_z}}) do
    x in min_x..max_x && y in min_y..max_y and z in min_z..max_z
  end

  def bounds(lava) do
    {xs, ys, zs} = Enum.reduce(lava, {[], [], []}, fn {x, y, z}, {xs, ys, zs} ->
      {[x | xs], [y | ys], [z | zs]}
    end)
    {{-1, -1, -1}, {Enum.max(xs) + 1, Enum.max(ys) + 1, Enum.max(zs) + 1}}
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      line |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    end)
  end
end
