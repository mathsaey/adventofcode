import AOC

aoc 2022, 4 do
  def p1(input), do: solve(input, fn {l, r} -> superset?(l, r) end)
  def p2(input), do: solve(input, fn {l, r} -> overlap?(l, r) end)

  def solve(input, filter) do
    input |> String.split("\n") |> Enum.map(&parse_line/1) |> Enum.filter(filter) |> Enum.count()
  end

  def superset?(l, r), do: contained?(l, r) or contained?(r, l)
  def contained?(f1..t1, f2..t2), do: f1 >= f2 and t1 <= t2
  def overlap?(f..t, r), do: (f in r) or (t in r) or superset?(f..t, r)

  def parse_line(str) do
    ~r/(\d+)-(\d+),(\d+)-(\d+)/
    |> Regex.run(str)
    |> tl()
    |> Enum.map(&String.to_integer/1)
    |> then(fn [lfrom, lto, rfrom, rto] -> {lfrom..lto, rfrom..rto} end)
  end
end
