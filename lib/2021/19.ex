import AOC

aoc 2021, 19 do
  # https://www.euclideanspace.com/maths/algebra/matrix/transforms/examples/index.htm
  orientations = [
    [[1, 0, 0], [0, 1, 0], [0, 0, 1]],   # Unmodified
    [[1, 0, 0], [0, 0, -1], [0, 1, 0]],  # 90
    [[1, 0, 0], [0, -1, 0], [0, 0, -1]], # 180
    [[1, 0, 0], [0, 0, 1], [0, -1, 0]],  # 270
  ]
  rotations = [
    [[1, 0, 0], [0, 1, 0], [0, 0, 1]],   # Unmodified
    [[0, 1, 0], [-1, 0, 0], [0, 0, 1]],  # z 90
    [[-1, 0, 0], [0, -1, 0], [0, 0, 1]], # z 180
    [[0, -1, 0], [1, 0, 0], [0, 0, 1]],  # z 270
    [[0, 0, -1], [0, 1, 0], [1, 0, 0]],  # y 90
    [[0, 0, 1], [0, 1, 0], [-1, 0, 0]],  # y 270
    # y 180 is the same as z 180
  ]

  # Yes, there probably is a better way to generate this :)
  @translations (for rotation <- rotations, orientation <- orientations do
    # Multiply rotation matrix with orientation matrix
    transposed = orientation |> Enum.zip() |> Enum.map(&Tuple.to_list/1)
    for row <- rotation do
      for col <- transposed do
        Enum.zip(row, col) |> Enum.map(fn {l, r} -> l * r end) |> Enum.sum()
      end
    end
  end)

  def p1, do: input_string() |> parse() |> merge_scanners() |> elem(0) |> MapSet.size()

  def p2 do
    input_string()
    |> parse()
    |> merge_scanners()
    |> elem(1)
    |> distances()
    |> Map.keys()
    |> Enum.map(fn d -> d |> Enum.map(&abs/1) |> Enum.sum() end)
    |> Enum.max()
  end

  def merge_scanners([hd | tl]), do: merge_scanners(MapSet.new(hd), [[0,0,0]], tl)

  def merge_scanners(merged, beacons, []), do: {merged, beacons}

  def merge_scanners(merged_beacons, beacons, [scanner_beacons | scanners]) do
    distances = distances(merged_beacons)
    translations = all_translations(scanner_beacons)
    all_distances = Enum.map(translations, fn {m, t} -> {m, distances(t)} end)

    all_distances
    |> Stream.map(fn {m, d} -> {m, matching_distances(d, distances)} end)
    |> Enum.find(fn {_, d} -> map_size(d) >= 12 end)
    |> case do
      {transformation, matching_distances} ->
        {distance, {scanner_beacon, _}} = matching_distances |> Enum.take(1) |> hd()
        range_difference = distance(scanner_beacon, elem(distances[distance], 0))

        scanner_beacons
        |> Enum.map(&translate(transformation, &1))
        |> Enum.map(&distance(&1, range_difference))
        |> MapSet.new()
        |> MapSet.union(merged_beacons)
        |> merge_scanners([range_difference | beacons], scanners)

      nil ->
        merge_scanners(merged_beacons, beacons, scanners ++ [scanner_beacons])
    end
  end

  def all_translations(beacons) do
    Enum.map(@translations, fn t -> {t, Enum.map(beacons, &translate(t, &1))} end)
  end

  def translate(m, v), do: Enum.map(m, &dot(&1, v))

  def dot(v1, v2), do: Enum.zip(v1, v2) |> Enum.map(fn {l, r} -> l * r end) |> Enum.sum()

  def matching_distances(d1, d2), do: Map.take(d1, Map.keys(d2))

  def distances(beacons) do
    beacons
    |> Enum.flat_map(fn beacon -> beacons |> Enum.map(&{distance(beacon, &1), {beacon, &1}}) end)
    |> Enum.reject(fn {_, {b1, b2}} -> b1 == b2 end)
    |> Map.new()
  end

  def distance([lx, ly, lz], [rx, ry, rz]), do: [lx - rx, ly - ry, lz - rz]

  def parse(string) do
    string
    |> String.split("\n\n")
    |> Enum.map(&String.split(&1, "\n"))
    |> Enum.map(&tl/1)
    |> Enum.map(&parse_scanner/1)
  end

  def parse_scanner(lst) do
    lst |> Enum.map(fn str ->
      str |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
  end
end
