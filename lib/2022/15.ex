import AOC

aoc 2022, 15 do
  @p1_row 2000000
  @p2_bounds 4000000

  def p1(input) do
    {sensors, beacons} = parse(input)
    range = sensors |> Enum.flat_map(&range_for_row(&1, @p1_row)) |> Enum.reduce(&merge/2)
    beacons_in_range = beacons |> Enum.count(fn {x, y} -> y == @p1_row and x in range end)
    Range.size(range) - beacons_in_range
  end

  def p2(input) do
    {sensors, beacons} = parse(input)
    sensors
    |> Task.async_stream(&perimeter(&1, beacons, sensors, @p2_bounds), timeout: :infinity)
    |> Stream.flat_map(fn {:ok, lst} -> lst end)
    |> Enum.uniq()
    |> then(fn [{x, y}] -> x * 4000000 + y end)
  end

  def perimeter({sx, sy, d}, beacons, sensors, max_coord) do
    for x <- (sx - (d + 1))..(sx + (d + 1)),
      y <- [sy - ((d + 1) - abs(x - sx)), sy + ((d + 1) - abs(x - sx))],
      x in 0..max_coord, y in 0..max_coord, {x, y} not in beacons,
      not in_range?(sensors, {x, y}),
      uniq: true do
        {x, y}
    end
  end

  def in_range?({sx, sy, d}, beacon), do: distance(beacon, {sx, sy}) <= d
  def in_range?(sensors, beacon), do: Enum.any?(sensors, &in_range?(&1, beacon))

  def merge(lf..lt//_, rf..rt//_), do: min(lf, rf)..max(lt, rt)

  def range_for_row({x, y, d}, row) do
    width = d - abs(row - y)
    if width > 0, do: [(x - width)..(x + width)], else: []
  end

  def distance({lx, ly}, {rx, ry}), do: abs(lx - rx) + abs(ly - ry)

  def parse(input) do
    coords = input |> String.split("\n") |> Enum.map(&parse_line/1)
    sensors = Enum.map(coords, fn {s = {x, y}, b} -> {x, y, distance(s, b)} end)
    beacons = MapSet.new(coords, fn {_, r} -> r end)
    {sensors, beacons}
  end

  def parse_line(line) do
    ~r/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/
    |> Regex.run(line, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
    |> then(fn [sx, sy, bx, by] -> {{sx, sy}, {bx, by}} end)
  end
end
