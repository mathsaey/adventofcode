import AOC

aoc 2023, 1 do
  def p1(input), do: solve(input, &extract_ints/1)
  def p2(input), do: solve(input, &extract_consume/1)

  def extract_ints(str) do
    str
    |> String.graphemes()
    |> Enum.map(fn <<c>> -> c end)
    |> Enum.filter(&(&1 in ?1..?9))
    |> Enum.map(&(&1 - ?0))
  end

  @digits ~w(one two three four five six seven eight nine)
  @digit_values @digits |> Enum.with_index(1) |> Map.new()

  # generate clauses like the following at compile time:
  # def extract_consume(<<"one", rest::binary>>), do: [1 | extract_consume("ne" <> rest)]
  for digit <- @digits do
    def extract_consume(str = <<unquote(digit), _::binary>>) do
      all_but_first = binary_part(str, 1, byte_size(str) - 1)
      [unquote(@digit_values[digit]) | extract_consume(all_but_first)]
    end
  end

  def extract_consume(<<c, rest::binary>>) when c in ?1..?9, do: [c - ?0 | extract_consume(rest)]
  def extract_consume(<<_::binary-size(1), rest::binary>>), do: extract_consume(rest)
  def extract_consume(""), do: []

  def solve(input, extractor) do
    input
    |> String.split("\n")
    |> Enum.map(extractor)
    |> Enum.map(&{List.first(&1), List.last(&1)})
    |> Enum.map(fn {l, r} -> l * 10 + r end)
    |> Enum.sum()
  end
end
