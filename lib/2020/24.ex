import AOC

aoc 2020, 24 do
  # https://www.redblobgames.com/grids/hexagons/
  # Took over most of the game of life logic from day 17

  def p1, do: initial() |> MapSet.size()
  def p2, do: initial() |> days(100) |> MapSet.size()

  def initial, do: parse() |> Stream.map(&path_to_coord/1) |> Enum.reduce(MapSet.new(), &flip/2)

  def flip(c, s), do: if(c in s, do: MapSet.delete(s, c), else: MapSet.put(s, c))
  def flipped(c, s), do: c |> adjacent() |> Enum.count(&(&1 in s))

  def days(flipped, 0), do: flipped
  def days(flipped, n), do: flipped |> day() |> days(n - 1)

  def day(flipped) do
    flipped
    |> Enum.flat_map(&adjacent/1)
    |> MapSet.new()
    |> Enum.filter(
      &case {&1 in flipped, flipped(&1, flipped)} do
        {true, n} when n == 0 or n > 2 -> false
        {false, 2} -> true
        {flip?, _} -> flip?
      end
    )
    |> MapSet.new()
  end

  def adjacent({x, y, z}) do
    for nx <- (x - 1)..(x + 1),
        ny <- (y - 1)..(y + 1),
        nz <- (z - 1)..(z + 1),
        nx + ny + nz == 0,
        {nx, ny, nz} != {x, y, z} do
      {nx, ny, nz}
    end
  end

  def path_to_coord(path) do
    Enum.reduce(path, {0, 0, 0}, fn
      :e, {x, y, z} -> {x + 1, y - 1, z}
      :w, {x, y, z} -> {x - 1, y + 1, z}
      :ne, {x, y, z} -> {x + 1, y, z - 1}
      :nw, {x, y, z} -> {x, y + 1, z - 1}
      :se, {x, y, z} -> {x, y - 1, z + 1}
      :sw, {x, y, z} -> {x - 1, y, z + 1}
    end)
  end

  def parse, do: input_stream() |> Stream.map(&parse_line/1)

  def parse_line(""), do: []
  def parse_line(<<"e", rest::binary>>), do: [:e | parse_line(rest)]
  def parse_line(<<"w", rest::binary>>), do: [:w | parse_line(rest)]
  def parse_line(<<"ne", rest::binary>>), do: [:ne | parse_line(rest)]
  def parse_line(<<"nw", rest::binary>>), do: [:nw | parse_line(rest)]
  def parse_line(<<"se", rest::binary>>), do: [:se | parse_line(rest)]
  def parse_line(<<"sw", rest::binary>>), do: [:sw | parse_line(rest)]
end
