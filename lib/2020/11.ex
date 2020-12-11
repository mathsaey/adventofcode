import AOC

aoc 2020, 11 do
  def p1, do: solve(&adjacent/2, 4)
  def p2, do: solve(&visible/2, 5)

  def parse do
    input_stream()
    |> Stream.map(&String.graphemes/1)
    |> Stream.map(&Stream.with_index/1)
    |> Stream.with_index()
    |> Stream.map(fn {s, i} -> {Enum.to_list(s), i} end)
    |> Stream.flat_map(fn {s, r} -> Stream.map(s, fn {status, c} -> {{r, c}, status} end) end)
    |> Map.new()
  end

  def solve(search, allowed) do
    parse() |> run(search, allowed) |> Map.values() |> Enum.count(&(&1 == "#"))
  end

  def run(prev, search, allowed) do
    new = turn(prev, search, allowed)
    if Map.equal?(new, prev), do: new, else: run(new, search, allowed)
  end

  def turn(m, search, allowed) do
    m
    |> Enum.map(fn
      {k, "."} -> {k, "."}
      {k, "L"} -> {k, if(Enum.any?(search.(k, m), &(&1 == "#")), do: "L", else: "#")}
      {k, "#"} -> {k, if(Enum.count(search.(k, m), &(&1 == "#")) >= allowed, do: "L", else: "#")}
    end)
    |> Map.new()
  end

  def adjacent({r, c}, m) do
    for row <- (r - 1)..(r + 1), col <- (c - 1)..(c + 1), not (row == r and col == c) do
      Map.get(m, {row, col}, ".")
    end
  end

  def visible({r, c}, m) do
    [
      fn {r, c} -> {r - 1, c} end,
      fn {r, c} -> {r + 1, c} end,
      fn {r, c} -> {r, c - 1} end,
      fn {r, c} -> {r, c + 1} end,
      fn {r, c} -> {r - 1, c - 1} end,
      fn {r, c} -> {r + 1, c + 1} end,
      fn {r, c} -> {r - 1, c + 1} end,
      fn {r, c} -> {r + 1, c - 1} end
    ]
    |> Enum.map(&find({r, c}, m, &1))
  end

  def find(k, m, next) do
    key = next.(k)
    case m[key] do
      "." -> find(key, m, next)
      nil -> "."
      any -> any
    end
  end
end
