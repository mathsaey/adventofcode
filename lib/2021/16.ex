import AOC

aoc 2021, 16 do
  def p1, do: input_string() |> to_tree() |> count_versions()
  def p2, do: input_string() |> to_tree() |> eval()

  def input_string(), do: super() |> String.trim()
  def to_tree(string), do: string |> :binary.decode_hex() |> parse_package() |> elem(0)

  def bits_to_int(bits) do
    s = bit_size(bits)
    <<int::size(s)>> = bits
    int
  end

  def parse_package(bits) do
    {v, tl} = parse_version(bits)
    {inner, tl} = parse(tl)
    {{v, inner}, tl}
  end

  def parse_packages(<<>>), do: []

  def parse_packages(bits) do
    {p, tl} = parse_package(bits)
    [p | parse_packages(tl)]
  end

  def parse_n_packages(tl, 0), do: {[], tl}

  def parse_n_packages(bits, n) do
    {p, tl} = parse_package(bits)
    {ps, tl} = parse_n_packages(tl, n - 1)
    {[p | ps], tl}
  end

  def parse(<<1::1, 0::1, 0::1, tl::bits>>), do: parse_literal(tl)
  def parse(<<o::3, tl::bits>>), do: parse_operator(tl, o)

  def parse_version(<<v::3, tl::bits>>), do: {v, tl}

  def parse_literal(bits), do: parse_literal(bits, <<>>)
  def parse_literal(<<0::1, b::4, tl::bits>>, res), do: {bits_to_int(<<res::bits, b::4>>), tl}
  def parse_literal(<<1::1, b::4, tl::bits>>, res), do: parse_literal(tl, <<res::bits, b::4>>)

  def parse_operator(<<0::1, size::15, sub::size(size), tl::bits>>, op) do
    {{op, parse_packages(<<sub::size(size)>>)}, tl}
  end

  def parse_operator(<<1::1, amount::11, tl::bits>>, op) do
    {operands, tl} = parse_n_packages(tl, amount)
    {{op, operands}, tl}
  end

  def count_versions(n) when is_number(n), do: 0
  def count_versions({_, l}) when is_list(l), do: l |> Enum.map(&count_versions/1) |> Enum.sum()
  def count_versions({v, p}), do: v + count_versions(p)

  def eval(n) when is_number(n), do: n
  def eval({0, lst}) when is_list(lst), do: lst |> Enum.map(&eval/1) |> Enum.sum()
  def eval({1, lst}) when is_list(lst), do: lst |> Enum.map(&eval/1) |> Enum.product()
  def eval({2, lst}) when is_list(lst), do: lst |> Enum.map(&eval/1) |> Enum.min()
  def eval({3, lst}) when is_list(lst), do: lst |> Enum.map(&eval/1) |> Enum.max()
  def eval({5, [l, r]}), do: if(eval(l) > eval(r), do: 1, else: 0)
  def eval({6, [l, r]}), do: if(eval(l) < eval(r), do: 1, else: 0)
  def eval({7, [l, r]}), do: if(eval(l) == eval(r), do: 1, else: 0)
  def eval({_version, r}), do: eval(r)
end
