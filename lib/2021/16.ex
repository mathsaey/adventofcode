import AOC

aoc 2021, 16 do
  def p1, do: input_string() |> to_tree() |> count_versions()
  def p2, do: input_string() |> to_tree() |> eval()

  def input_string(), do: super() |> String.trim()
  def to_tree(string), do: string |> hex_to_bits() |> parse_package() |> elem(0)

  def hex_to_bits(string) do
    string
    |> String.graphemes()
    |> Enum.map(&String.to_integer(&1, 16))
    |> Enum.map(&<<&1::4>>)
    |> Enum.reduce(<<>>, &<<&2::bits, &1::bits>>)
  end

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

  def parse(<<1::1, 0::1, 0::1, tl::bits>>), do: parse_lit(tl)
  def parse(<<o::3, tl::bits>>), do: parse_op(tl, o)

  def parse_version(<<v::3, tl::bits>>), do: {{:v, v}, tl}

  def parse_lit(bits), do: parse_lit(bits, <<>>)
  def parse_lit(<<0::1, b::4, tl::bits>>, res), do: {{:l, bits_to_int(<<res::bits, b::4>>)}, tl}
  def parse_lit(<<1::1, b::4, tl::bits>>, res), do: parse_lit(tl, <<res::bits, b::4>>)

  def parse_op(<<0::1, size::15, sub::size(size), tl::bitstring>>, op) do
    {{:o, op, parse_packages(<<sub::size(size)>>)}, tl}
  end

  def parse_op(<<1::1, amount::11, tl::bits>>, op) do
    {operands, tl} = parse_n_packages(tl, amount)
    {{:o, op, operands}, tl}
  end

  def count_versions({:v, v}), do: v
  def count_versions({:l, _}), do: 0
  def count_versions({:o, _, lst}), do: lst |> Enum.map(&count_versions/1) |> Enum.sum()
  def count_versions({t1, t2}), do: count_versions(t1) + count_versions(t2)

  def eval({{:v, _}, r}), do: eval(r)
  def eval({:l, n}), do: n
  def eval({:o, 0, lst}), do: lst |> Enum.map(&eval/1) |> Enum.sum()
  def eval({:o, 1, lst}), do: lst |> Enum.map(&eval/1) |> Enum.product()
  def eval({:o, 2, lst}), do: lst |> Enum.map(&eval/1) |> Enum.min()
  def eval({:o, 3, lst}), do: lst |> Enum.map(&eval/1) |> Enum.max()
  def eval({:o, 5, [l, r]}), do: if(eval(l) > eval(r), do: 1, else: 0)
  def eval({:o, 6, [l, r]}), do: if(eval(l) < eval(r), do: 1, else: 0)
  def eval({:o, 7, [l, r]}), do: if(eval(l) == eval(r), do: 1, else: 0)
end
