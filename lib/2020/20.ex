import AOC

aoc 2020, 20 do
  def p1(input) do
    grid = input |> parse() |> build_grid()

    {{min_x, _}, {max_x, _}} = grid |> Map.keys() |> Enum.min_max_by(&elem(&1, 0))
    {{_, min_y}, {_, max_y}} = grid |> Map.keys() |> Enum.min_max_by(&elem(&1, 1))

    [{min_x, min_y}, {min_x, max_y}, {max_x, min_y}, {max_x, max_y}]
    |> Enum.map(&Map.fetch!(grid, &1))
    |> Enum.map(&elem(&1, 0))
    |> Enum.reduce(1, &(&1 * &2))
  end

  def p2(input) do
    input
    |> parse()
    |> build_grid()
    |> to_picture()
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> find_all()
    |> count()
  end

  # Monster Hunting
  # ---------------

  @monster_size 15
  @monster [~r/..................#./, ~r/#....##....##....###/, ~r/.#..#..#..#..#..#.../]

  def count({str, monsters}) do
    monsters = length(monsters)
    pounds = str |> String.graphemes() |> Enum.count(&(&1 == "#"))
    pounds - monsters * @monster_size
  end

  def find_all(str) do
    str
    |> to_list()
    |> orientations()
    |> Enum.map(&to_text/1)
    |> Enum.map(&{&1, find(&1)})
    |> Enum.filter(&(elem(&1, 1) != []))
    |> hd()
  end

  def find(str) do
    str
    |> String.split("\n")
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.filter(fn s ->
      s
      |> Enum.zip(@monster)
      |> Enum.map(fn {s, r} -> Regex.match?(r, s) end)
      |> Enum.all?()
    end)
  end

  def to_list(str), do: str |> String.split("\n") |> Enum.map(&String.graphemes/1)
  def to_text(lst), do: lst |> Enum.map(&Enum.join/1) |> Enum.join("\n")

  # Picture Creation
  # ----------------

  def to_picture(grid) do
    grid
    |> Enum.map(fn {k, {_, v}} -> {k, v} end)
    |> Enum.map(&drop_edges/1)
    |> Enum.group_by(fn {{_, y}, _} -> y end)
    |> Enum.map(&join_row/1)
    |> Enum.sort_by(fn {k, _} -> k end, :desc)
    |> Enum.map(&elem(&1, 1))
    |> Enum.concat()
  end

  def drop_edges({k, v}), do: {k, drop_edges(v)}

  def drop_edges(tile) when is_list(tile) do
    tile |> tl() |> List.delete_at(-1) |> Enum.map(&(&1 |> tl() |> List.delete_at(-1)))
  end

  def join_row({k, lst}) do
    v =
      lst
      |> Enum.sort_by(fn {{x, _}, _} -> x end)
      |> Enum.map(fn {_, tile} -> tile end)
      |> join_row()

    {k, v}
  end

  def join_row(tiles) do
    tiles |> Enum.zip() |> Enum.map(&Tuple.to_list/1) |> Enum.map(&Enum.concat/1)
  end

  # Grid Creation
  # -------------

  def build_grid(tiles) do
    [{id, tile, edges} | tiles] =
      Enum.map(tiles, fn {id, tile} -> {id, tile, all_edges(tile)} end)

    edges = edges |> Enum.take(4) |> edge_entry({0, 0})

    build_grid(%{{0, 0} => {id, tile}}, edges, tiles)
  end

  def build_grid(grid, _, []), do: grid

  def build_grid(grid, free_edges, [tile = {_, _, edges} | tiles]) do
    if edge = Enum.find(edges, &Map.has_key?(free_edges, &1)) do
      {grid, free_edges} = place(grid, free_edges, tile, Map.get(free_edges, edge), edge)
      build_grid(grid, free_edges, tiles)
    else
      build_grid(grid, free_edges, tiles ++ [tile])
    end
  end

  def place(g, f, t, {{x, y}, :top}, e), do: place(g, f, &bot/1, {x, y + 1}, t, e)
  def place(g, f, t, {{x, y}, :bot}, e), do: place(g, f, &top/1, {x, y - 1}, t, e)
  def place(g, f, t, {{x, y}, :left}, e), do: place(g, f, &right/1, {x - 1, y}, t, e)
  def place(g, f, t, {{x, y}, :right}, e), do: place(g, f, &left/1, {x + 1, y}, t, e)

  def place(grid, free, dir, {x, y}, {id, tile, _}, edge) do
    tile = adjust(tile, &(dir.(&1) == edge))
    if Map.has_key?(grid, {x, y}), do: IO.puts("FUCK")
    grid = Map.put(grid, {x, y}, {id, tile})
    free = tile |> edges() |> edge_entry({x, y}) |> Map.merge(free)

    {grid, free}
  end

  def fit?(tile, fun), do: fun.(tile)
  def adjust(tile, fun), do: tile |> orientations() |> Enum.find(&fit?(&1, fun))

  def edge_entry(edges, {x, y}) do
    edges
    |> Enum.zip([:top, :bot, :left, :right] |> Enum.map(&{{x, y}, &1}))
    |> Map.new()
  end

  # Tile Logic
  # ----------

  def orientations(tile), do: rotations(tile) ++ rotations(flip(tile))
  def rotations(tile), do: tile |> Stream.iterate(&rot/1) |> Enum.take(4)

  def edges(tile), do: [top(tile), bot(tile), left(tile), right(tile)]

  def all_edges(tile) do
    edges = edges(tile)
    edges ++ Enum.map(edges, &Enum.reverse/1)
  end

  def top(tile), do: tile |> hd()
  def bot(tile), do: tile |> List.last()
  def left(tile), do: tile |> Enum.map(&hd/1)
  def right(tile), do: tile |> Enum.map(&List.last/1)

  def flip(tile), do: Enum.reverse(tile)

  def rot(tile) do
    tile
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.reverse/1)
  end

  # Parsing
  # -------

  def parse(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(&parse_tile/1)
    |> Map.new()
  end

  def parse_tile(<<"Tile ", n::binary-4, ":\n", tile::binary>>) do
    tile = tile |> String.split("\n") |> Enum.map(&String.graphemes/1)
    {String.to_integer(n), tile}
  end
end
