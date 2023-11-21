import AOC

aoc 2021, 21 do
  def p1(input) do
    {p1, p2} = parse(input)

    1..100
    |> Stream.cycle()
    |> Stream.chunk_every(3)
    |> Stream.map(&Enum.sum(&1))
    |> Stream.transform({p1, p2}, fn
      roll, {player, other_player} ->
        player = update(player, roll)
        {[player], {other_player, player}}
    end)
    |> Stream.take_while(fn {_, score} -> score < 1000 end)
    |> Enum.reduce({3, 0}, fn {_, score}, {rolls, _} -> {rolls + 3, score} end)
    |> then(fn {rolls, score} -> rolls * score end)
  end

  def p2(input), do: input |> parse() |> turn() |> Tuple.to_list() |> Enum.max()

  @moves for(f <- 1..3, s <- 1..3, t <- 1..3, do: f + s + t)
  |> Enum.frequencies()
  |> Enum.to_list()

  def turn({_, {_, score}}) when score >= 21, do: {0, 1}

  def turn({player, other}) do
    @moves
    |> Enum.map(fn {move, freq} ->
      {p2_wins, p1_wins} = memoized(&turn/1, {other, update(player, move)})
      {freq * p1_wins, freq * p2_wins}
    end)
    |> Enum.reduce(fn {e1, e2}, {a1, a2} -> {e1 + a1, e2 + a2} end)
  end

  def memoized(fun, arg) do
    case Process.get(arg) do
      nil ->
        res = fun.(arg)
        Process.put(arg, res)
        res
      val ->
        val
    end
  end

  def move(cur, spaces), do: rem((cur + spaces) - 1, 10) + 1

  def update({pos, score}, roll) do
    n_pos = move(pos, roll)
    score = score + n_pos
    {n_pos, score}
  end

  def parse(string) do
    string
    |> String.split("\n")
    |> Enum.map(fn <<"Player ", _, " starting position: ", p>> -> {p - ?0, 0} end)
    |> List.to_tuple()
  end
end
