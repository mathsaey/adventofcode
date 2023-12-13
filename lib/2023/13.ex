import AOC

aoc 2023, 13 do
  def p1(input), do: solve(input, 0)
  def p2(input), do: solve(input, 1)
  def solve(input, diff), do: input |> parse() |> Enum.map(&score(&1, diff)) |> Enum.sum()

  def score({rows, cols}, diff) do
    if r = get_reflection(rows, diff) do
      (r + 1) * 100
    else
      get_reflection(cols, diff) + 1
    end
  end

  def get_reflection(tup, diff) do
    Enum.find(0..tuple_size(tup) - 2, &diff_by?(tup, &1, &1 + 1, diff))
  end

  def diff_by?(tup, l, r, 0) when l < 0 or r >= tuple_size(tup), do: true
  def diff_by?(tup, l, r, _) when l < 0 or r >= tuple_size(tup), do: false

  def diff_by?(tup, l, r, b) do
    diff = diff_count(elem(tup, l), elem(tup, r))
    b - diff >= 0 and diff_by?(tup, l - 1, r + 1, b - diff)
  end

  def diff_count(l, r), do: diff_count(l, r, 0)
  def diff_count(<<>>, <<>>, n), do: n
  def diff_count(<<c, lr::binary>>, <<c, rr::binary>>, n), do: diff_count(lr, rr, n)
  def diff_count(<<_, lr::binary>>, <<_, rr::binary>>, n), do: diff_count(lr, rr, n + 1)

  def parse(input) do
    input |> String.split("\n\n") |> Enum.map(&rows/1) |> Enum.map(&{&1, cols(&1)})
  end

  def rows(input), do: input |> String.split("\n") |> List.to_tuple()

  def cols(rows) do
    rows
    |> Tuple.to_list()
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.join/1)
    |> List.to_tuple()
  end
end
