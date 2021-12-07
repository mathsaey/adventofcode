import AOC

aoc 2021, 7 do
  def p1, do: solve(input(), &p1_fuel/2)
  def p2, do: solve(input(), &p2_fuel/2)

  def input do
    input_string() |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  def solve(crabs, fuel_fn) do
    {min, max} = Enum.min_max(crabs)
    min..max |> Enum.map(&total_fuel(&1, crabs, fuel_fn)) |> Enum.min()
  end

  def total_fuel(pos, crabs, fuel_fn), do: Enum.reduce(crabs, 0, &(&2 + fuel_fn.(&1, pos)))

  def p1_fuel(from, to), do: max(from, to) - min(from, to)
  def p2_fuel(from, to), do: termial(p1_fuel(from, to))
  def termial(n), do: div(n * (n + 1), 2)
end
