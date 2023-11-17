import AOC

aoc 2018, 1 do
  def p1(input) do
    input |> parse() |> Enum.sum()
  end

  def p2(input) do
    input
    |> parse()
    |> Stream.cycle()
    |> Enum.reduce_while({0, MapSet.new([0])}, fn val, {sum , set} ->
      sum = sum + val
      if sum in set, do: {:halt, sum}, else: {:cont, {sum, MapSet.put(set, sum)}}
    end)
  end

  def parse(input), do: input |> String.split() |> Enum.map(&String.to_integer/1)
end
