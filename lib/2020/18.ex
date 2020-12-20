import AOC

aoc 2020, 18 do
  def p1, do: run(&p1/1)

  def p1(lst), do: p1(lst, [nil])
  def p1([], [es]), do: es
  def p1([:l | tl], es), do: p1(tl, [nil | es])
  def p1([:r | tl], [e | es]), do: p1([e | tl], es)
  def p1([op | tl], [e | es]) when op in [:+, :*], do: p1(tl, [[op, e] | es])
  def p1([lhs | tl], [nil | es]), do: p1(tl, [lhs | es])
  def p1([rhs | tl], [[op, lhs] | es]), do: p1(tl, [[op, lhs, rhs] | es])

  def p2, do: run(&p2/1)

  def p2(lst), do: p2(lst, [])
  # stop when we are left with a single expression
  def p2([], [e]), do: e
  # Push l onto the stack if we encounter it, keep reducing :r until we find :l
  def p2([:l | tl], es), do: p2(tl, [:l | es])
  def p2([:r | tl], [e, :l | es]), do: p2(tl, [e | es])
  # "seed" the stack with the lefmost value after a left parenthesis and at the start
  # This could be replaced by pattern matching inside :+ and :* reductions, but this is easier
  def p2([lhs | tl], []), do: p2(tl, [lhs])
  def p2([lhs | tl], [:l | es]), do: p2(tl, [lhs, :l | es])
  # We can always reduce + if there are no parenthesis
  def p2(lst, [lhs, :+, rhs | es]), do: p2(lst, [[:+, lhs, rhs] | es])
  # We can only reduce * at the end of the string or at the right parenthesis
  def p2([], [lhs, :*, rhs | es]), do: p2([], [[:*, lhs, rhs] | es])
  def p2([:r | tl], [lhs, :*, rhs | es]), do: p2([:r | tl], [[:*, lhs, rhs] | es])
  # Shift in every other case
  def p2([hd | tl], es), do: p2(tl, [hd | es])

  def run(parse) do
    input_stream() |> Enum.map(&tokens/1) |> Enum.map(parse) |> Enum.map(&eval/1) |> Enum.sum()
  end

  def eval(n) when is_integer(n), do: n
  def eval([:+, l, r]), do: eval(l) + eval(r)
  def eval([:*, l, r]), do: eval(l) * eval(r)

  def tokens(""), do: []
  def tokens(<<" ", r::binary>>), do: tokens(r)
  def tokens(<<"+", r::binary>>), do: [:+ | tokens(r)]
  def tokens(<<"*", r::binary>>), do: [:* | tokens(r)]
  def tokens(<<"(", r::binary>>), do: [:l | tokens(r)]
  def tokens(<<")", r::binary>>), do: [:r | tokens(r)]
  def tokens(<<n, r::binary>>), do: [String.to_integer(<<n>>) | tokens(r)]
end
