import AOC

aoc 2019, 3 do
  def pre, do: input_string() |> String.split() |> Enum.map(&process_path/1)

  def p1 do
    [s1, s2] = pre() |> Enum.map(&MapSet.new/1)
    MapSet.intersection(s1, s2) |> Enum.map(&manhattan_distance/1) |> Enum.min()
  end

  def p2 do
    [m1, m2] = pre() |> Enum.map(&to_map/1)
    merged = Map.merge(m1, m2, fn _, v1, v2 -> v1 + v2 end)

    # Figure out crossings as in p1
    [s1, s2] = pre() |> Enum.map(&MapSet.new/1)
    intersections = MapSet.intersection(s1, s2)

    # Convert them to distances, find one with least amount of steps
    intersections
    |> Enum.map(&Map.get(merged, &1))
    |> Enum.min()
  end

  # Convert a path of "directions" into a list of coordinates
  defp process_path(str) do
    str
    |> String.split(",")
    |> Enum.map(&String.split_at(&1, 1))
    |> Enum.map(fn {d, s} -> {d, String.to_integer(s)} end)
    |> Enum.flat_map_reduce({0,0}, &coords/2)
    |> elem(0)
  end

  defp coords({"U", steps}, pos), do: do_coords(pos, steps, 1, :y)
  defp coords({"D", steps}, pos), do: do_coords(pos, steps, -1, :y)
  defp coords({"L", steps}, pos), do: do_coords(pos, steps, -1, :x)
  defp coords({"R", steps}, pos), do: do_coords(pos, steps, 1, :x)

  defp do_coords(pos, steps, sign, axis) do
    {
      gen_coords(pos, sign .. (steps * sign), axis),
      last(pos, steps, sign, axis)
    }
  end

  # More efficient than always getting last element
  defp last({x, y}, steps, sign, :x), do: {x + (sign * steps), y}
  defp last({x, y}, steps, sign, :y), do: {x, y + (sign * steps)}

  # Generate a list of coordinates from a starting point and a range
  defp gen_coords(pos, range, x_or_y) do
    range |> Enum.to_list() |> Enum.map(&gen_tup(pos, &1, x_or_y))
  end

  defp gen_tup({x, y}, val, :x), do: {x + val, y}
  defp gen_tup({x, y}, val, :y), do: {x, y + val}

  defp manhattan_distance({x, y}), do: abs(x) + abs(y)

  defp to_map(coords) do
    {_, m} = Enum.reduce(coords, {1, %{}}, fn coord, {ctr, map} ->
      {ctr + 1, Map.put_new(map, coord, ctr)}
    end)
    m
  end
end
