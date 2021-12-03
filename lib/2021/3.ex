import AOC

aoc 2021, 3 do
  def input_stream, do: super() |> parse()

  def p1, do: solve(&gamma/1, &epsilon/1)
  def p2, do: solve(&oxygen/1, &scrubber/1)

  defp solve(lhs_fun, rhs_fun) do
    lhs = lhs_fun.(input_stream())
    rhs = rhs_fun.(input_stream())
    dec(lhs) * dec(rhs)
  end

  defp parse(stream) do
    Stream.map(stream, fn str ->
      str |> String.graphemes() |> Enum.map(&String.to_integer/1)
    end)
  end

  defp cols(stream) do
    lst = stream |> Enum.map(&List.to_tuple/1)
    row_length = lst |> hd() |> tuple_size()

    0..(row_length - 1)
    |> Enum.map(fn i -> Enum.map(lst, &elem(&1, i)) end)
  end

  defp gamma(stream) do
    stream
    |> cols()
    |> Enum.map(&Enum.frequencies/1)
    |> Enum.map(&Enum.max_by(&1, fn {_, f} -> f end))
    |> Enum.map(&elem(&1, 0))
  end

  defp epsilon(stream), do: stream |> gamma() |> Enum.map(&(if &1 == 0, do: 1, else: 0))

  defp oxygen(stream) do
    find(stream, fn
      %{0 => f0, 1 => f1} when f0 > f1 -> 0
      %{0 => f0, 1 => f1} when f0 < f1 -> 1
      %{0 => f0, 1 => f1} when f0 == f1 -> 1
    end)
  end

  defp scrubber(stream) do
    find(stream, fn
      %{0 => f0, 1 => f1} when f0 > f1 -> 1
      %{0 => f0, 1 => f1} when f0 < f1 -> 0
      %{0 => f0, 1 => f1} when f0 == f1 -> 0
    end)
  end

  defp find(lst, bit_criteria) do
    lst |> Enum.map(&{&1, &1}) |> do_find(bit_criteria)
  end

  defp do_find([{_, val}], _), do: val

  defp do_find(vals, bit_criteria) do
    bit = vals |> Enum.map(fn {[hd | _], _} -> hd end) |> Enum.frequencies() |> bit_criteria.()

    vals
    |> Enum.filter(fn {[h | _], _} -> h == bit end)
    |> Enum.map(fn {[_ | tl], val} -> {tl, val} end)
    |> do_find(bit_criteria)
  end

  defp dec(lst), do: Integer.undigits(lst, 2)
end
