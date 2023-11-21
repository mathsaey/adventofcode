import AOC

aoc 2021, 24 do
  def p1(input), do: solve(input, &p1_solver/1)
  def p2(input), do: solve(input, &p2_solver/1)

  def solve(input, solver) do
    input |> parse() |> vars() |> to_constraints() |> solve_constraints(solver)
  end

  def p1_solver(n) when n >= 0, do: {9, 9 - n}
  def p1_solver(n), do: {9 + n, 9}

  def p2_solver(n) when n >= 0, do: {1 + n, 1}
  def p2_solver(n), do: {1, 1 - n}

  def solve_constraints(constraints, solver) do
    constraints
    |> Enum.reduce(Tuple.duplicate(nil, 14), fn {l_idx, r_idx, n}, digits ->
      {l, r} = solver.(n)
      digits |> put_elem(l_idx, l) |> put_elem(r_idx, r)
    end)
    |> Tuple.to_list()
    |> Integer.undigits()
  end

  def to_constraints(stream) do
    stream
    |> Stream.with_index()
    |> Enum.reduce({[], []}, &to_constraints/2)
    |> elem(1)
  end

  def to_constraints({{true, _, y}, idx}, {stack, constraints}) do
    {[{idx, y} | stack], constraints}
  end

  def to_constraints({{false, x, _}, idx}, {[{s_idx, s_y} | stack], constraints}) do
    {stack, [{idx, s_idx, s_y + x} | constraints]}
  end

  def vars(stream) do
    stream
    |> Stream.chunk_every(18)
    |> Stream.map(&find_vars/1)
  end

  def find_vars(lst) do
    {
      {:div, :z, 1} in lst,
      lst |> Enum.find(&match?({:add, :x, n} when is_integer(n), &1)) |> elem(2),
      lst |> Enum.drop_while(&(not match?({:add, :y, :w}, &1))) |> tl() |> hd() |> elem(2)
    }
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn
      <<"inp ", a::binary-size(1)>> -> {:inp, String.to_atom(a)}
      <<"add ", rest::binary>> -> parse_binary_op(:add, rest)
      <<"mul ", rest::binary>> -> parse_binary_op(:mul, rest)
      <<"div ", rest::binary>> -> parse_binary_op(:div, rest)
      <<"mod ", rest::binary>> -> parse_binary_op(:mod, rest)
      <<"eql ", rest::binary>> -> parse_binary_op(:eql, rest)
    end)
  end

  def parse_binary_op(op, <<a::binary-size(1), " ", b::binary>>) do
    case b do
      bin = <<b>> when b in ?w..?z -> {op, String.to_atom(a), String.to_atom(bin)}
      _ -> {op, String.to_atom(a), String.to_integer(b)}
    end
  end
end
