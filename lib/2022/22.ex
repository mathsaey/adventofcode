import AOC

aoc 2022, 22 do
  @opposite %{left: :right, right: :left, up: :down, down: :up}
  @clockwise %{right: :down, down: :left, left: :up, up: :right}
  @counter %{right: :up, up: :left, left: :down, down: :right}
  @scores %{right: 0, down: 1, left: 2, up: 3}

  def p1(input), do: solve(input, &wrap_around/3)
  def p2(input), do: solve(input, &wrap_cube/3)

  def solve(input, wrap) do
    {map, path} = input |> parse()
    next(path, initial_pos(map), map, wrap) |> score()
  end

  def initial_pos(m) do
    {m |> Enum.filter(fn {{_, y}, _} -> y == 1 end) |> Enum.min() |> elem(0), :right}
  end

  def score({{x, y}, dir}), do: @scores[dir] + x * 4 + y * 1000

  def next([], pos, _, _), do: pos

  def next([:clock | tl], {pos, dir}, map, wrap), do: next(tl, {pos, @clockwise[dir]}, map, wrap)
  def next([:counter | tl], {pos, dir}, map, wrap), do: next(tl, {pos, @counter[dir]}, map, wrap)
  def next([0 | tl], {pos, dir}, map, wrap), do: next(tl, {pos, dir}, map, wrap)

  def next([n | tl], {pos, dir}, map, wrap) do
    {next_pos, next_dir} = next_pos(pos, dir, map, wrap)

    case map[next_pos] do
      :wall -> next(tl, {pos, dir}, map, wrap)
      :pass -> next([n - 1 | tl], {next_pos, next_dir}, map, wrap)
    end
  end

  def next_pos(pos, dir, map, wrap) do
    {next_pos, next_dir} = next_point(dir, pos)
    if Map.has_key?(map, next_pos), do: {next_pos, next_dir}, else: wrap.(dir, pos, map)
  end

  def next_point(:left, {x, y}), do: {{x - 1, y}, :left}
  def next_point(:right, {x, y}), do: {{x + 1, y}, :right}
  def next_point(:up, {x, y}), do: {{x, y - 1}, :up}
  def next_point(:down, {x, y}), do: {{x, y + 1}, :down}

  # Part 1
  # ------

  def wrap_around(dir, pos, map), do: {do_wrap_around(dir, pos, min_max(pos, map)), dir}

  def do_wrap_around(:left, {_, y}, {_, max_x, _, _}), do: {max_x, y}
  def do_wrap_around(:right, {_, y}, {min_x, _, _, _}), do: {min_x, y}
  def do_wrap_around(:up, {x, _}, {_, _, _, max_y}), do: {x, max_y}
  def do_wrap_around(:down, {x, _}, {_, _, min_y, _}), do: {x, min_y}

  def min_max({x, y}, map) do
    cs = Map.keys(map)

    {{minx, _}, {maxx, _}} =
      cs |> Enum.filter(&(elem(&1, 1) == y)) |> Enum.min_max_by(&elem(&1, 0))

    {{_, miny}, {_, maxy}} =
      cs |> Enum.filter(&(elem(&1, 0) == x)) |> Enum.min_max_by(&elem(&1, 1))

    {minx, maxx, miny, maxy}
  end

  # Part 2
  # ------

  def wrap_cube(from_dir, {x, y}, map) do
    cube = cube_connections(map)
    {from_idx, from_side} = Enum.find(cube, fn {_, %{x: xr, y: yr}} -> x in xr and y in yr end)
    to_side = cube[from_side[from_dir]]
    to_dir = to_side |> Enum.find(fn {_, v} -> v == from_idx end) |> elem(0)

    {rel_coord, inv_coord} =
      case from_dir do
        h when h in [:left, :right] -> {y - from_side.y.first, from_side.y.last - y}
        v when v in [:up, :down] -> {x - from_side.x.first, from_side.x.last - x}
      end

    dirs = MapSet.new([from_dir, to_dir])

    coord =
      if(
        (:up in dirs and :down in dirs) or (:left in dirs and :up in dirs) or
          (:right in dirs and :down in dirs),
        do: rel_coord,
        else: inv_coord
      )

    to_dir
    |> case do
      :up -> {{to_side.x.first + coord, to_side.y.first}, :down}
      :down -> {{to_side.x.first + coord, to_side.y.last}, :up}
      :left -> {{to_side.x.first, to_side.y.first + coord}, :right}
      :right -> {{to_side.x.last, to_side.y.first + coord}, :left}
    end
  end

  def cube_connections(map) do
    sides = connected_sides(map)

    sides
    |> inner_corners()
    |> Enum.flat_map(&[&1 | follow_edges(&1, sides)])
    |> Enum.reduce(sides, fn {{s1, e1, _}, {s2, e2, _}}, sides ->
      sides
      |> put_in([s1, e1], s2)
      |> put_in([s2, e2], s1)
    end)
  end

  def connected_sides(map) do
    sides = identify_sides(map)

    Map.new(sides, fn {idx, side} ->
      {idx,
       Enum.reduce([:left, :right, :up, :down], side, fn dir, side ->
         if idx = Enum.find_index(sides, &side_match?(dir, side, elem(&1, 1))) do
           Map.put(side, dir, idx)
         else
           side
         end
       end)}
    end)
  end

  def side_match?(:left, %{x: lx.._, y: y}, %{x: _..rx, y: y}), do: rx + 1 == lx
  def side_match?(:right, %{x: _..rx, y: y}, %{x: lx.._, y: y}), do: rx + 1 == lx
  def side_match?(:up, %{x: x, y: ty.._}, %{x: x, y: _..by}), do: by + 1 == ty
  def side_match?(:down, %{x: x, y: _..by}, %{x: x, y: ty.._}), do: by + 1 == ty
  def side_match?(_, _, _), do: false

  def identify_sides(map) do
    face_size = face_size(map)
    max_y = map |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()
    max_x = map |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()

    for y <- 1..max_y//face_size do
      for x <- 1..max_x//face_size, Map.has_key?(map, {x, y}) do
        %{x: x..(x + face_size - 1), y: y..(y + face_size - 1)}
      end
    end
    |> List.flatten()
    |> Enum.with_index()
    |> Map.new(fn {map, idx} -> {idx, map} end)
  end

  def face_size(map) do
    map
    |> Map.keys()
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
    |> Enum.map(fn {_, lst} -> Enum.min_max(lst) end)
    |> Enum.map(fn {f, t} -> t - f + 1 end)
    |> Enum.min()
  end

  def inner_corners(sides) do
    sides
    |> Enum.filter(fn {_, s} ->
      (Map.has_key?(s, :left) or Map.has_key?(s, :right)) and
        (Map.has_key?(s, :up) or Map.has_key?(s, :down))
    end)
    |> Enum.flat_map(fn {_, side} ->
      []
      |> maybe_add_corner(:up, :left, side)
      |> maybe_add_corner(:up, :right, side)
      |> maybe_add_corner(:down, :left, side)
      |> maybe_add_corner(:down, :right, side)
    end)
  end

  def maybe_add_corner(lst, d1, d2, side) when is_map_key(side, d1) and is_map_key(side, d2) do
    [{{side[d1], d2, d1}, {side[d2], d1, d2}} | lst]
  end

  def maybe_add_corner(lst, _, _, _), do: lst

  def follow_edges({e1 = {s1, _, _}, e2 = {s2, _, _}}, sides) do
    ne1 = {ns1, _, _} = next_edge(e1, sides)
    ne2 = {ns2, _, _} = next_edge(e2, sides)

    if ns1 == s1 and ns2 == s2 do
      []
    else
      [{ne1, ne2} | follow_edges({ne1, ne2}, sides)]
    end
  end

  def next_edge({side, edge, dir}, sides) do
    if next = sides[side][dir] do
      {next, edge, dir}
    else
      {side, dir, @opposite[edge]}
    end
  end

  # Parsing
  # -------

  def parse(input) do
    [map, path] = String.split(input, "\n\n")
    {parse_map(map), parse_path(path)}
  end

  def parse_map(map) do
    map
    |> String.split("\n")
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.codepoints()
      |> Enum.with_index(1)
      |> Enum.flat_map(fn
        {" ", _} -> []
        {".", x} -> [{{x, y}, :pass}]
        {"#", x} -> [{{x, y}, :wall}]
      end)
    end)
    |> Map.new()
  end

  def parse_path(path) do
    path
    |> String.codepoints()
    |> Enum.chunk_by(fn
      "L" -> :l
      "R" -> :r
      _ -> :n
    end)
    |> Enum.map(fn
      ["L"] -> :counter
      ["R"] -> :clock
      s -> s |> Enum.join() |> String.to_integer()
    end)
  end
end
