import AOC

aoc 2023, 7 do
  def p1(input), do: solve(input, 11, &match_type/1)
  def p2(input), do: solve(input, 1,  &match_with_joker/1)

  def match_type(%{cards: cards}), do: cards |> card_freqs() |> get_type()

  def match_with_joker(%{cards: [1, 1, 1, 1, 1]}), do: get_type([5])
  def match_with_joker(%{cards: cards}) do
    regulars = Enum.reject(cards, &(&1 == 1))
    jokers = 5 - length(regulars)
    [max | rest] = card_freqs(regulars)
    get_type([max + jokers | rest])
  end

  @types [[1, 1, 1, 1, 1], [2, 1, 1, 1], [2, 2, 1], [3, 1, 1], [3, 2], [4, 1], [5]]
  def get_type(freqs), do: Enum.find_index(@types, &(&1 == freqs))
  def card_freqs(cards), do: cards |> Enum.frequencies() |> Map.values() |> Enum.sort(:desc)

  def solve(input, j_value, get_type_fun) do
    fixed_sign_values = %{"T" => 10, "Q" => 12, "K" => 13, "A" => 14}
    sign_values = Map.put(fixed_sign_values, "J", j_value)

    input
    |> parse(sign_values)
    |> Enum.map(fn hand -> Map.put(hand, :type, get_type_fun.(hand)) end)
    |> Enum.sort(&compare/2)
    |> Enum.with_index(1)
    |> Enum.map(fn {%{bid: bid}, rank} -> bid * rank end)
    |> Enum.sum()
  end

  def compare(%{type: lt, cards: l}, %{type: rt, cards: r}) when lt == rt, do: l <= r
  def compare(%{type: l}, %{type: r}), do: l <= r

  def parse(input, sign_values) do
    input |> String.split("\n") |> Enum.map(&parse_line(&1, sign_values))
  end

  def parse_line(line, sign_values) do
    [cards, bid] = String.split(line)
    %{
      cards: cards |> String.graphemes() |> Enum.map(&parse_card(&1, sign_values)),
      bid: String.to_integer(bid)
    }
  end

  def parse_card(<<c>>, _) when c in ?2..?9, do: c - ?0
  def parse_card(sign, sign_values), do: sign_values[sign]
end
