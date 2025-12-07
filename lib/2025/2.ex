import AOC

aoc 2025, 2 do
  def p1(input), do: solve(input, &if(rem(&1, 2) == 0, do: div(&1, 2)..div(&1, 2), else: []))
  def p2(input), do: solve(input, &if(&1 == 1, do: [1], else: (1..div(&1, 2))))

  def solve(input, pattern_range_fun) do
    input
    |> parse()
    |> Enum.flat_map(&Enum.filter(&1, fn i -> repeating_pattern?(i, pattern_range_fun) end))
    |> Enum.sum()
  end

  def repeating_pattern?(i, pattern_range_fun) do
    digits = Integer.digits(i)
    length = length(digits)
    repeating_pattern?(pattern_range_fun.(length), digits, length)
  end

  def repeating_pattern?(pattern_length_range, digits, length) do
    pattern_length_range
    |> Enum.filter(&rem(length, &1) == 0)
    |> Enum.any?(fn i ->
      {prefix, rest} = Enum.split(digits, i)
      repeats?(prefix, prefix, rest)
    end)
  end

  def repeats?(_, [], []), do: true
  def repeats?(prefix, [], lst), do: repeats?(prefix, prefix, lst)
  def repeats?(prefix, [hd | rem], [hd | lst]), do: repeats?(prefix, rem, lst)
  def repeats?(_, _, _), do: false

  def parse(input) do
    input
    |> String.split(",")
    |> Enum.map(&String.trim_leading/1)
    |> Enum.map(fn range ->
      [start, stop] = range |> String.split("-") |> Enum.map(&String.to_integer/1)
      start..stop
    end)
  end
end
