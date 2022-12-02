import AOC

aoc 2022, 2 do
  def p1(input), do: input |> parse(&parse_shape/1) |> Enum.map(&round_score/1) |> Enum.sum()

  def p2(input) do
    input
    |> parse(&parse_goal/1)
    |> Enum.map(fn
      {s, :lose} -> {s, lose_from(s)}
      {s, :win} -> {s, win_from(s)}
      {s, :draw} -> {s, s}
    end)
    |> Enum.map(&round_score/1)
    |> Enum.sum()
  end

  def parse(input, parse_r_fun) do
    input
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&parse_round(&1, parse_r_fun))
  end

  def parse_round([l, r], parse_r_fun), do: {parse_shape(l), parse_r_fun.(r)}

  def parse_shape(s) when s in ["A", "X"], do: :rock
  def parse_shape(s) when s in ["B", "Y"], do: :paper
  def parse_shape(s) when s in ["C", "Z"], do: :scissors

  def parse_goal("X"), do: :lose
  def parse_goal("Y"), do: :draw
  def parse_goal("Z"), do: :win

  def result_score(l, r) do
    cond do
      win?(r, l) -> 6
      win?(l, r) -> 0
      true -> 3
    end
  end

  @shape_scores %{rock: 1, paper: 2, scissors: 3}
  def round_score({l, r}), do: @shape_scores[r] + result_score(l, r)

  @winning_combinations [rock: :scissors, scissors: :paper, paper: :rock]
  def win?(l,r) when {l, r} in @winning_combinations, do: true
  def win?(_,_), do: false

  def win_from(s), do: @winning_combinations |> Enum.find(fn {_, l} -> l == s end) |> elem(0)
  def lose_from(s), do: @winning_combinations |> Enum.find(fn {w, _} -> w == s end) |> elem(1)
end
