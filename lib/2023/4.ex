import AOC

aoc 2023, 4 do
  def p1(input) do
    input
    |> parse()
    |> Enum.map(&matching_numbers/1)
    |> Enum.reject(&(&1 == 0))
    |> Enum.map(&(2 ** (&1 - 1)))
    |> Enum.sum()
  end

  def p2(input) do
    cards = parse(input)
    amounts = Map.new(cards, fn %{card: i} -> {i, 1} end)

    cards
    |> Enum.map(&Map.put(&1, :gives, matching_numbers(&1)))
    |> Enum.reject(&(&1.gives == 0))
    |> Enum.map(&{&1.card, &1.card + 1 .. &1.card + &1.gives})
    |> Enum.reduce(amounts, fn {card, range}, amounts ->
      copies = amounts[card]
      Enum.reduce(range, amounts, fn i, amounts ->
        Map.replace_lazy(amounts, i, &(&1 + copies))
      end)
    end)
    |> Map.values()
    |> Enum.sum()
  end

  def matching_numbers(card), do: MapSet.intersection(card.winning, card.have) |> MapSet.size()

  def parse(input), do: input |> String.split("\n") |> Enum.map(&parse_line/1)

  def parse_line(line) do
    [_, card, winning, have] = Regex.run(~r/Card\s+(\d+):(.*)\|(.*)/, line)
    %{card: String.to_integer(card), winning: parse_numbers(winning), have: parse_numbers(have)}
  end

  def parse_numbers(n), do: n |> String.split() |> Enum.map(&String.to_integer/1) |> MapSet.new()
end
