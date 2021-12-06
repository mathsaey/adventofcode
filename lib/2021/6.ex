import AOC

aoc 2021, 6 do
  def p1, do: solve(80)
  def p2, do: solve(256)
  def solve(days), do: input() |> to_map() |> simulate_loop(days) |> Map.values() |> Enum.sum()

  def input do
    input_string() |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  def to_map(lst) do
    Enum.reduce(lst, %{}, fn timer, map -> Map.update(map, timer, 1, &(&1 + 1)) end)
  end

  def simulate(state) do
    state
    |> Enum.flat_map(fn
      {0, amount} -> [{6, amount}, {8, amount}]
      {timer, amount} -> [{timer - 1, amount}]
    end)
    |> Enum.reduce(%{}, fn
      {timer, amount}, map -> Map.update(map, timer, amount, &(&1 + amount))
    end)
  end

  def simulate_loop(state, 0), do: state
  def simulate_loop(state, n), do: state |> simulate() |> simulate_loop(n - 1)
end
