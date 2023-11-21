import AOC

aoc 2021, 11 do
  def p1(input) do
    input
    |> parse()
    |> Stream.iterate(&step/1)
    |> Stream.map(&Enum.count(&1, fn {_, v} -> v == 0 end))
    |> Stream.take(101)
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> parse()
    |> Stream.iterate(&step/1)
    |> Stream.map(&Enum.all?(&1, fn {_, v} -> v == 0 end))
    |> Stream.take_while(&not/1)
    |> Enum.to_list()
    |> length()
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&Integer.digits/1)
    |> Enum.with_index()
    |> Enum.flat_map(fn {lst, y} ->
      lst |> Enum.with_index() |> Enum.map(fn {el, x} -> {{x, y}, el} end)
    end)
    |> Map.new()
  end

  def step(map), do: map |> increase_all() |> flash() |> reset()

  def increase_all(map), do: map |> Map.new(fn {k, v} -> {k, v + 1} end)

  def flash(map) do
    keys = map |> Enum.filter(fn {_, v} -> v != :flash and v > 9 end) |> Enum.map(&elem(&1, 0))
    map = Enum.reduce(keys, map, &flash/2)
    if keys == [], do: map, else: flash(map)
  end

  def flash(coord, map) do
    map = Map.put(map, coord, :flash)
    coord |> adjacent() |> Enum.reduce(map, &increase/2)
  end

  def adjacent({x, y}), do: for(x <- (x - 1)..(x + 1), y <- (y - 1)..(y + 1), do: {x, y})

  def increase(coord, map) when is_map_key(map, coord), do: %{map | coord => inc(map[coord])}
  def increase(_, map), do: map

  def inc(:flash), do: :flash
  def inc(x), do: x + 1

  def reset(map), do: map |> Map.new(fn {k, v} -> {k, if(v > 9, do: 0, else: v)} end)
end
