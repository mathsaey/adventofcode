import AOC

aoc 2023, 22 do
  def p1(input) do
    input
    |> parse()
    |> drop()
    |> supported_by()
    |> then(fn supported_by ->
      bricks = map_size(supported_by)
      supporting_bricks = supported_by |> supporting_bricks() |> length()
      bricks - supporting_bricks
    end)
  end

  def p2(input) do
    bricks = input |> parse() |> drop()
    supports = supporting(bricks)
    supported_by = supported_by(bricks)

    supported_by
    |> supporting_bricks()
    |> Enum.map(&simulate_removal(&1, supported_by, supports))
    |> Enum.sum()
  end

  def simulate_removal(brick, supported_by, supports) do
    simulate_removal(Qex.new([brick]), 0, supported_by, supports)
  end

  def simulate_removal(queue, count, supported_by, supports) do
    if Enum.empty?(queue) do
      count
    else
      {to_remove, queue} = Qex.pop!(queue)
      lost_support_bricks = Map.get(supports, to_remove, [])

      supported_by =
        Enum.reduce(lost_support_bricks, supported_by, fn el, supported_by ->
          Map.update!(supported_by, el, &List.delete(&1, to_remove))
        end)

      unsupported_bricks = Enum.filter(lost_support_bricks, &supported_by[&1] == [])

      simulate_removal(
        Qex.join(queue, Qex.new(unsupported_bricks)),
        count + length(unsupported_bricks),
        supported_by,
        supports
      )
    end
  end

  def supporting_bricks(supported_by) do
    supported_by
    |> Map.values()
    |> Enum.filter(&(length(&1) == 1))
    |> Enum.map(&hd/1)
    |> Enum.uniq()
  end

  def supporting(bricks), do: bricks |> Enum.map(&{&1, supporting(&1, bricks)}) |> Map.new()
  def supporting(brick, all_bricks), do: Enum.filter(all_bricks, &supports?(brick, &1))

  def supported_by(bricks), do: bricks |> Enum.map(&{&1, supported_by(&1, bricks)}) |> Map.new()
  def supported_by(brick, all_bricks), do: Enum.filter(all_bricks, &supports?(&1, brick))

  def supports?({lx, ly, _..lz}, {rx, ry, rz.._}) do
    lz == rz - 1 and not Range.disjoint?(lx, rx) and not Range.disjoint?(ly, ry)
  end

  def drop(bricks), do: bricks |> Enum.reduce({[], %{}}, &drop/2) |> elem(0) |> bottom_to_top()

  def drop(t = {xs, ys, zf..zt}, {dropped, z_cache}) do
    lowest_z = Enum.max(for(x <- xs, y <- ys, do: Map.get(z_cache, {x, y}, 0))) + 1
    t = {xs, ys, lowest_z..(lowest_z + (zt - zf))}
    {[t | dropped], update_z_cache(z_cache, t)}
  end

  def update_z_cache(z_cache, {xs, ys, zs}) do
    for(x <- xs, y <- ys, z <- zs, do: {x, y, z})
    |> Enum.reduce(z_cache, fn {x, y, z}, z_cache ->
      Map.update(z_cache, {x, y}, z, fn prev_z -> max(z, prev_z) end)
    end)
  end

  def bottom_to_top(bricks), do: List.keysort(bricks, 2)

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      ~r/(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)/
      |> Regex.run(line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)
      |> then(fn [xl, yl, zl, xr, yr, zr] -> {xl..xr, yl..yr, zl..zr} end)
    end)
    |> bottom_to_top()
  end
end
