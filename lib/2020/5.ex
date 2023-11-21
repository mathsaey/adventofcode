import AOC

aoc 2020, 5 do
  def p1(input), do: input |> String.split("\n") |> Enum.map(&id/1) |> Enum.max()

  def p2(input) do
    ids = input |> String.split("\n") |> Enum.map(&id/1) |> MapSet.new()
    0..(127 * 8 + 8) |> Enum.find(&(&1 not in ids and (&1 - 1) in ids and (&1 + 1) in ids))
  end

  def id(<<row::binary-size(7), col::binary-size(3)>>) do
    row = decode(row, 0..127, "F", "B")
    col = decode(col, 0..7, "L", "R")
    row * 8 + col
  end

  def decode(str, range, lower, upper) do
    str
    |> String.graphemes()
    |> Enum.reduce(range, fn
      ^lower, range -> %{range | last: range.last - round(Enum.count(range) / 2)}
      ^upper, range -> %{range | first: range.first + round(Enum.count(range) / 2)}
    end)
    |> Enum.at(0)
  end
end
