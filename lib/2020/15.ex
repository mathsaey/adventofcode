import AOC

aoc 2020, 15 do
  def parse(input), do: input |> String.split(",") |> Enum.map(&String.to_integer/1)

  def seed(input) do
    {{el, turn}, lst} = input |> parse() |> Enum.with_index(1) |> List.pop_at(-1)
    {Map.new(lst), turn, el}
  end

  def turn({map, turn, prev}) do
    {res, map} =  Map.get_and_update(map, prev, fn
      nil -> {0, turn}
      prev -> {turn - prev, turn}
    end)
    {map, turn + 1, res}
  end

  def run(input, until) do
    input
    |> seed()
    |> Stream.iterate(&turn/1)
    |> Stream.drop_while(fn {_, turn, _} -> turn < until end)
    |> Stream.take(1)
    |> Enum.to_list()
    |> hd()
    |> elem(2)
  end

  def p1(input), do: run(input, 2020)
  def p2(input), do: run(input, 30000000)
end
