import AOC

aoc 2023, 5 do
  def p1(input) do
    {seeds, maps} = parse(input)

    Enum.map(seeds, fn seed ->
      Enum.reduce(maps, seed, fn map, seed ->
        Enum.find_value(map, seed, fn %{range: range, diff: diff} ->
          if seed in range, do:  seed + diff end)
      end)
    end)
    |> Enum.min()
  end

  def p2(input) do
    {seeds, maps} = parse(input)
    seed_ranges = seed_ranges(seeds)

    maps
    |> Enum.reduce(seed_ranges, &map_over_seed_ranges/2)
    |> Enum.map(fn from.._ -> from end)
    |> Enum.min()
  end

  def seed_ranges(seeds) do
    seeds
    |> Enum.chunk_every(2)
    |> Enum.map(fn [l, r] -> l..l + r - 1 end)
  end

  def map_over_seed_ranges(map, seed_ranges) do
    Enum.flat_map(seed_ranges, fn seed_range ->
      {unmodifieds, modifieds} =
        Enum.reduce(map, {[seed_range], []}, fn range, {unmodifieds, modifieds} ->
          {unmodifieds, new_modifieds} =
            unmodifieds
            |> Enum.map(&split_seed_range(&1, range))
            |> Enum.unzip()

          {List.flatten(unmodifieds), List.flatten(new_modifieds) ++ modifieds}
        end)
        unmodifieds ++ modifieds
    end)
  end

  def split_seed_range(seed_range = s_from..s_to, map_range = %{range: m_from..m_to, diff: d}) do
    cond do
      Range.disjoint?(seed_range, map_range.range) ->
        # seed_range and map_range don't overlap
        {[seed_range], []}
      s_from < m_from and s_to > m_to ->
        # seed_range is larger than map_range on both sides
        before = s_from..m_from - 1
        inside = m_from + d..m_to + d
        behind = m_to + 1..s_to
        {[before, behind], [inside]}
      s_from >= m_from and s_to <= m_to ->
        # seed_range is completely contained in map_range
        {[s_from + d..s_to + d], []}
      s_from < m_from ->
        # seed_range starts before map_range, ends inside map_range
        before = s_from..m_from - 1
        inside = m_from + d..s_to + d
        {[before], [inside]}
      s_to > m_to ->
        # seed_range starts inside map_range, ends after map_range
        inside = s_from + d..m_to + d
        behind = m_to + 1..s_to
        {[inside], [behind]}
    end
  end

  def parse(input) do
    [seeds | maps] = input |> String.split("\n\n")
    {parse_seeds(seeds), Enum.map(maps, &parse_map/1)}
  end

  def parse_seeds(str) do
    str |> String.trim_leading("seeds: ") |> String.split(" ") |> Enum.map(&String.to_integer/1)
  end

  def parse_map(str), do: str |> String.split("\n") |> tl() |> Enum.map(&parse_range/1)

  def parse_range(str) do
    [dst, src, len] = str |> String.split(" ") |> Enum.map(&String.to_integer/1)
    diff = if src > dst, do: -src + dst, else: dst - src
    %{range: src..src + len - 1, diff: diff}
  end
end
