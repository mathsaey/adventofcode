import AOC

aoc 2020, 13 do
  def p1 do
    {t0, ids} = parse()
    {id, t} = ids |> Enum.map(&{&1, first_bus(&1, t0)}) |> Enum.min_by(&elem(&1, 1))
    id * (t - t0)
  end

  def p2 do
    {p, o} = parse() |> elem(1) |> with_offset() |> Enum.reduce(&merge/2)
    if o < 0, do: abs(o), else: p - o
  end

  def parse do
    [t0, ids, ""] = input_string() |> String.split("\n")
    {String.to_integer(t0), ids |> String.split(",") |> Enum.map(&parse_entry/1)}
  end

  def parse_entry("x"), do: "x"
  def parse_entry(x), do: String.to_integer(x)

  def schedule(id), do: Stream.iterate(id, &(&1 + id))
  def with_offset(ids), do: ids |> Enum.with_index() |> Enum.reject(&(elem(&1, 0) == "x"))

  def first_bus(id, t0) do
    id |> schedule() |> Stream.drop_while(&(&1 < t0)) |> Stream.take(1) |> Enum.to_list() |> hd()
  end

  # Based on: https://math.stackexchange.com/questions/2218763/how-to-find-lcm-of-two-numbers-when-one-starts-with-an-offset
  def merge({p, o}, {ap, ao}) do
    {gcd, s, _} = gcd_ext(p, ap)
    period = lcm(p, ap)
    offset = rem(-div(o - ao, gcd) * s * p + o, period)
    {period, rem(offset, period)}
  end

  def lcm(a, b), do: div(abs(a * b), Integer.gcd(a, b))

  # Returns three numbers {g, s, t} where s.a + t.b = gcd(a,b) = g
  # See: https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
  def gcd_ext(a, 0), do: {a, 1, 0}
  def gcd_ext(0, b), do: {b, 0, 1}

  def gcd_ext(a, b) do
    {g, s, t} = gcd_ext(b, rem(a, b))
    {g, t, s - div(a, b) * t}
  end
end
