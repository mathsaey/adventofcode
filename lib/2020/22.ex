import AOC

aoc 2020, 22 do
  import Kernel, except: [round: 1]

  def p1(input), do: input |> parse() |> play()
  def p2(input), do: input |> parse() |> game() |> elem(1) |> score()

  def play({[], l}), do: score(l)
  def play({l, []}), do: score(l)
  def play(tup), do: tup |> round() |> play()

  def round({[p1 | p1s], [p2 | p2s]}) when p1 > p2, do: {p1s ++ [p1, p2], p2s}
  def round({[p1 | p1s], [p2 | p2s]}) when p2 > p1, do: {p1s, p2s ++ [p2, p1]}

  def game({l1, l2}) when is_list(l1) and is_list(l2) do
    game({%{cards: l1, prev: MapSet.new()}, %{cards: l2, prev: MapSet.new()}})
  end

  def game({%{cards: l}, %{cards: []}}), do: {1, l}
  def game({%{cards: []}, %{cards: l}}), do: {2, l}

  def game({%{cards: c1 = [p1 | p1s], prev: s1}, %{cards: c2 = [p2 | p2s], prev: s2}}) do
    winner = cond do
      c1 in s1 or c2 in s2 -> {1, c1}
      length(p1s) >= p1 and length(p2s) >= p2 -> game({Enum.take(p1s, p1), Enum.take(p2s, p2)})
      p1 > p2 -> {1, c1}
      p2 > p1 -> {2, c2}
    end

    case winner do
      {1, _} ->
        game({
          %{cards: p1s ++ [p1, p2], prev: MapSet.put(s1, c1)},
          %{cards: p2s, prev: MapSet.put(s2, c2)}
        })
      {2, _} ->
        game({
          %{cards: p1s, prev: MapSet.put(s1, c1)},
          %{cards: p2s ++ [p2, p1], prev: MapSet.put(s2, c2)}
        })
    end
  end

  def score(lst) do
    lst
    |> Enum.reduce({length(lst), 0}, fn e, {i, s} -> {i - 1, s + e * i} end)
    |> elem(1)
  end

  def parse(input) do
    [p1, p2] = input |> String.split("\n\n") |> Enum.map(&parse_player/1)
    {p1, p2}
  end

  def parse_player(<<"Player ", _, ":\n", rest::binary>>) do
    rest |> String.trim() |> String.split("\n") |> Enum.map(&String.to_integer/1)
  end
end
