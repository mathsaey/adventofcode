import AOC

aoc 2021, 16 do
  def p1, do: input_string() |> to_tree() |> count_versions()
  def p2, do: input_string() |> to_tree() |> eval()

  def input_string(), do: super() |> String.trim()

  def to_tree(string), do: string |> hex_to_bitstring() |> parse_package() |> elem(0)

  def hex_to_bitstring(string) do
    string
    |> String.graphemes()
    |> Enum.map(&String.to_integer(&1, 16))
    |> Enum.map(&integer_to_binary_bs/1)
    |> Enum.into(<<>>)
  end

  def integer_to_binary_bs(n) do
    bitstring = n |> Integer.digits(2) |> Enum.map(&<<&1>>) |> Enum.into(<<>>)
    padding_size = 4 - byte_size(bitstring)
    <<padding::binary-size(padding_size), _::binary>> = <<0, 0, 0, 0>>
    padding <> bitstring
  end

  def bits_to_int(bs), do: bs |> :erlang.binary_to_list() |> Integer.undigits(2)

  def parse_package(binary) do
    {v, tl} = parse_version(binary)
    {inner, tl} = parse(tl)
    {{v, inner}, tl}
  end

  def parse_packages(<<>>), do: []

  def parse_packages(binary) do
    {p, tl} = parse_package(binary)
    [p | parse_packages(tl)]
  end

  def parse_n_packages(tl, 0), do: {[], tl}

  def parse_n_packages(binary, n) do
    {p, tl} = parse_package(binary)
    {ps, tl} = parse_n_packages(tl, n - 1)
    {[p | ps], tl}
  end

  def parse(<<1, 0, 0, tl::binary>>), do: parse_lit(tl)
  def parse(<<o::binary-size(3), tl::binary>>), do: parse_op(tl, bits_to_int(o))

  def parse_version(<<v::binary-size(3), tl::binary>>), do: {{:v, bits_to_int(v)}, tl}

  def parse_lit(bitstring), do: parse_lit(bitstring, <<>>)
  def parse_lit(<<1, b::binary-size(4), tl::binary>>, res), do: parse_lit(tl, res <> b)
  def parse_lit(<<0, b::binary-size(4), tl::binary>>, res), do: {{:l, bits_to_int(res <> b)}, tl}

  def parse_op(<<0, tl::binary>>, op) do
    <<length::binary-size(15), tl::binary>> = tl
    length = bits_to_int(length)
    <<sub::binary-size(length), tl::binary>> = tl
    {{:o, op, parse_packages(sub)}, tl}
  end

  def parse_op(<<1, tl::binary>>, op) do
    <<length::binary-size(11), tl::binary>> = tl
    length = bits_to_int(length)
    {operands, tl} = parse_n_packages(tl, length)
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
