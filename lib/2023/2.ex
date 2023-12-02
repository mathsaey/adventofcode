import AOC

aoc 2023, 2 do
  def p1(input) do
    input
    |> parse()
    |> Enum.with_index(1)
    |> Enum.map(fn {draws, game} -> {max_seen(draws), game} end)
    |> Enum.filter(fn {draws, _} ->
      draws.red <= 12 and draws.green <= 13 and draws.blue <= 14
    end)
    |> Enum.map(fn {_draws, game} -> game end)
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> parse()
    |> Enum.map(&max_seen/1)
    |> Enum.map(&Map.values/1)
    |> Enum.map(&Enum.product/1)
    |> Enum.sum()
  end

  def max_seen(games) do
    Enum.reduce(games, &Map.merge(&1, &2, fn _, l, r -> max(l, r) end))
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    line
    |> String.split(":")
    |> List.last()
    |> String.split(";")
    |> Enum.map(&parse_game/1)
  end

  def parse_game(game) do
    game
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [amount, colour] ->
      {String.to_existing_atom(colour), String.to_integer(amount)}
    end)
    |> Map.new()
  end
end
