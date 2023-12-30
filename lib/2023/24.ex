import AOC

aoc 2023, 24 do
  # I can't math anymore, solution based on https://www.youtube.com/watch?v=guOyA7Ijqgk
  #
  def p1(input) do
    input
    |> parse()
    |> Enum.map(&drop_z/1)
    |> Enum.map(&normalize/1)
    |> pairs()
    |> Enum.reject(&parallel?/1)
    |> Enum.map(&{&1, intersection(&1)})
    |> Enum.filter(&in_area?(&1, 200000000000000, 400000000000000))
    |> Enum.filter(&future?/1)
    |> length()
  end

  @range -500..500

  def p2(input) do
    stones = parse(input)
    impossible = impossible_velocities(stones)

    @range
    # First we find a valid x, y coordinate
    |> x_y_stream()
    # Remove all velocities that cannot possibly contain an answer
    |> Stream.reject(fn {x, _} -> Enum.any?(impossible.x, &(x in &1)) end)
    |> Stream.reject(fn {_, y} -> Enum.any?(impossible.y, &(y in &1)) end)
    # Caculate the intersection point for all the rocks with their velocity adjusted relative to
    # a starting rock which "stands still" (i.e. which has velocity (0,0,0))
    |> Stream.map(fn {x, y} ->
      stones
      |> Stream.map(&drop_z/1)
      |> Stream.map(fn p = %{vx: vx, vy: vy} -> %{p | vx: vx - x, vy: vy - y} end)
      |> Stream.map(&normalize/1)
      |> Stream.take(4)
      |> Stream.chunk_every(2, 1, :discard)
      |> Stream.map(fn [l, r] -> if(parallel?({l, r}), do: false, else: intersection({l, r})) end)
      |> Enum.reduce_while(nil, fn
        false, _ -> {:halt, false}
        c, nil -> {:cont, c}
        c, p when c == p -> {:cont, c}
        _, _ -> {:halt, false}
      end)
      |> then(&{{x, y}, &1})
    end)
    # Filter out all {x, y}s which don't have the same intersection for all rocks
    |> Stream.filter(fn {_, i} -> i end)
    # Add valid z coordinates
    |> Stream.flat_map(fn {{x, y}, i} -> Stream.map(@range, fn z -> {{x, y, z}, i} end) end)
    |> Stream.reject(fn {{_, _, z}, _} -> Enum.any?(impossible.z, &(z in &1)) end)
    |> Stream.map(fn {{x, y, z}, i} ->
      stones
      |> Stream.map(fn p = %{vx: vx, vy: vy, vz: vz} -> %{p | vx: vx - x, vy: vy - y, vz: vz - z} end)
      |> Stream.map(&Map.put(&1, :t, div(trunc(i.x) - &1.sx, &1.vx)))
      |> Stream.map(&(&1.sz + &1.t * &1.vz))
      |> Stream.take(4)
      |> Enum.to_list()
      |> Enum.reduce_while(nil, fn
        z, nil -> {:cont, z}
        z, prev -> if(z == prev, do: {:cont, z}, else: {:halt, false})
      end)
      |> then(&{{x, y, z}, i, &1})
    end)
    |> Stream.filter(fn {_, _, i} -> i end)
    |> Enum.at(0)
    |> then(fn {_, %{y: y, x: x}, z} -> x + y + z end)
    |> trunc()
  end

  def x_y_stream(range) do
    Stream.flat_map(range, fn x -> Stream.map(range, fn y -> {x, y} end) end)
  end

  def possible_values_stream(min, max) do
    min..max
    |> Stream.flat_map(fn x -> Stream.map(min..max, fn y -> {x, y} end) end)
    |> Stream.flat_map(fn {x, y} -> Stream.map(min..max, fn z -> {x, y, z} end) end)
  end

  # Make a list of ranges that cannot contain valid vectors.
  # Idea from:
  # https://old.reddit.com/r/adventofcode/comments/18pptor/2023_day_24_part_2java_is_there_a_trick_for_this/kepxbew/
  def impossible_velocities(stones) do
    stones
    |> pairs()
    |> Enum.flat_map(fn {l, r} ->
      [{:x, l.sx, l.vx, r.sx, r.vx}, {:y, l.sy, l.vy, r.sy, r.vy}, {:z, l.sz, l.vz, r.sz, r.vz}]
    end)
    |> Enum.filter(fn {_, ls, lv, rs, rv} -> (ls > rs and lv > rv) or (rs > ls and rv > lv) end)
    |> Enum.map(fn {d, _, lv, _, rv} ->
      {low, high} = if(lv < rv, do: {lv, rv}, else: {rv, lv})
      {d, low..high}
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    # Merge ranges by sorting them and merging them if they overlap
    |> Enum.map(fn {d, lst} ->
      lst
      |> Enum.sort()
      |> Enum.reduce({[], nil}, fn
        range, {[], nil} -> {[], range}
        from..to, {ranges, pfrom..pto} when from >= pfrom and from <= pto -> {ranges, pfrom..to}
        range, {ranges, prev} -> {[prev | ranges], range}
      end)
      |> then(fn {ranges, prev} -> {d, [prev | ranges]} end)
    end)
    |> Map.new()
  end


  def pairs([]), do: []
  def pairs([hd | tl]), do: Enum.map(tl, &{hd, &1}) ++ pairs(tl)

  def parallel?({l, r}), do: l.a * r.b == r.a * l.b
  def in_area?({_, p}, min, max), do: p.x >= min and p.x <= max and p.y >= min and p.y <= max

  def normalize(s), do: Map.merge(s, %{a: s.vy, b: -s.vx, c: s.vy * s.sx - s.vx * s.sy})

  def intersection({l, r}) do
    %{
      x: (l.c * r.b - r.c * l.b) / (l.a * r.b - r.a * l.b),
      y: (r.c * l.a - l.c * r.a) / (l.a * r.b - r.a * l.b)
    }
  end

  def future?({{l, r}, p}), do: future?(l, p) and future?(r, p)
  def future?(s, p), do: (p.x - s.sx) * s.vx >= 0 and (p.y - s.sy) * s.vy >= 0

  def drop_z(stone), do: Map.drop(stone, [:sz, :vz])

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      ~r/(\d+), (\d+), (\d+) @\s+(-?\d+),\s+(-?\d+),\s+(-?\d+)/
      |> Regex.run(line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)
      |> then(fn [sx, sy, sz, vx, vy, vz] ->
        %{sx: sx, sy: sy, sz: sz, vx: vx, vy: vy, vz: vz}
      end)
    end)
  end
end
