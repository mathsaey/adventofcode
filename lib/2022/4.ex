import AOC

aoc 2022, 4 do
  def p1(input), do: solve(input, fn {l, r} -> contained?(l, r) or contained?(r, l) end)
  def p2(input), do: solve(input, fn {l, r} -> not Range.disjoint?(l, r) end)

  def solve(input, filter) do
    input |> String.split("\n") |> Enum.map(&parse_line/1) |> Enum.count(filter)
  end

  def contained?(f1..t1, f2..t2), do: f1 >= f2 and t1 <= t2

  def parse_line(str) do
    ~r/(\d+)-(\d+),(\d+)-(\d+)/
    |> Regex.run(str)
    |> tl()
    |> Enum.map(&String.to_integer/1)
    |> then(fn [lfrom, lto, rfrom, rto] -> {lfrom..lto, rfrom..rto} end)
  end
end
