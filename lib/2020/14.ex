import AOC

aoc 2020, 14 do
  import Bitwise

  def p1, do: run(&p1/2)
  def p1({:msk, msk}, {mem, _}), do: {mem, msk}
  def p1({:mem, k, v}, {mem, msk}), do: {Map.put(mem, k, mask_val(v, msk)), msk}

  def p2, do: run(&p2/2)
  def p2({:msk, msk}, {mem, _}), do: {mem, msk}
  def p2({:mem, k, v}, {mem, msk}) do
    {k |> mask_addr(msk) |> Enum.reduce(mem, &Map.put(&2, &1, v)), msk}
  end

  def run(f), do: parse() |> Enum.reduce({%{}, nil}, f) |> elem(0) |> Map.values() |> Enum.sum()

  def mask(v, m, maskfn, postfn) do
    v |> int_to_binlst() |> pad() |> Enum.zip(m) |> Enum.map(maskfn) |> postfn.()
  end

  # Part 1 masking
  # --------------

  def mask_val(val, mask), do: mask(val, mask, &mask_val/1, &binlst_to_int/1)

  def mask_val({v, :x}), do: v
  def mask_val({_, v}), do: v

  # Part 2 masking
  # --------------

  def mask_addr(addr, mask), do: mask(addr, mask, &mask_addr/1, &floating/1)

  def mask_addr({_, 1}), do: 1
  def mask_addr({v, 0}), do: v
  def mask_addr({_, :x}), do: :x

  def floating([]), do: [[]]
  def floating([:x | tl]), do: tl |> floating() |> Enum.flat_map(&[[0 | &1], [1 | &1]])
  def floating([hd | tl]), do: tl |> floating() |> Enum.map(&[hd | &1])

  # Parsing
  # -------

  def parse(), do: input_stream() |> Enum.map(&entry/1)

  def entry(<<"mask = ", mask::binary>>), do: {:msk, parse_mask(mask)}

  def entry(input = <<"mem", _::binary>>) do
    [_, k, v] = Regex.run(~r/mem\[(\d+)\] = (\d+)/, input)
    {:mem, String.to_integer(k), String.to_integer(v)}
  end

  def parse_mask(""), do: []
  def parse_mask(<<"0", rest::binary>>), do: [0 | parse_mask(rest)]
  def parse_mask(<<"1", rest::binary>>), do: [1 | parse_mask(rest)]
  def parse_mask(<<"X", rest::binary>>), do: [:x | parse_mask(rest)]

  # Binary lists
  # ------------

  def pad(lst), do: pad(lst, 36 - length(lst))
  def pad(lst, 0), do: lst
  def pad(lst, n), do: [0 | pad(lst, n - 1)]

  def int_to_binlst(n, res \\ [])
  def int_to_binlst(n, res) when n < 2, do: [n | res]
  def int_to_binlst(n, res), do: int_to_binlst(div(n, 2), [rem(n, 2) | res])

  def binlst_to_int(lst), do: Enum.reduce(lst, 0, &(&2 <<< 1 ||| &1))
end
