import AOC

aoc 2019, 1 do
  def p1, do: p(&fuel/1)
  def p2, do: p(&total_fuel/1)

  def p(f) do
    input_stream()
    |> Stream.map(&String.to_integer/1)
    |> Stream.map(f)
    |> Enum.sum()
  end

  def fuel(mass), do: floor(mass / 3) - 2

  def total_fuel(mass) do
    case fuel(mass) do
      n when n <= 0 -> 0
      n -> n + total_fuel(n)
    end
  end
end
