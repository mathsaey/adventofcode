import AOC

aoc 2022, 13 do
  def p1(input) do
    input
    |> parse()
    |> Enum.map(&ord?/1)
    |> Enum.with_index(1)
    |> Enum.filter(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> parse()
    |> Enum.flat_map(fn {l, r} -> [l, r] end)
    |> Enum.concat([[[2]], [[6]]])
    |> Enum.sort(&ord?/2)
    |> find_key()
  end

  def find_key(lst) do
    p1 = Enum.find_index(lst, &(&1 == [[2]])) + 1
    p2 = Enum.find_index(lst, &(&1 == [[6]])) + 1
    p1 * p2
  end

  def ord?({l, r}), do: ord?(l, r)
  def ord?(l, r) when is_integer(l) and is_integer(r) and l < r, do: true
  def ord?(l, r) when is_integer(l) and is_integer(r) and l > r, do: false
  def ord?(l, r) when is_integer(l) and is_integer(r), do: :continue
  def ord?([lh | lt], [rh | rt]), do: if(is_boolean(r = ord?(lh, rh)), do: r, else: ord?(lt, rt))
  def ord?([], [_ | _]), do: true
  def ord?([_ | _], []), do: false
  def ord?([], []), do: :continue
  def ord?(l, r) when is_list(l) and is_integer(r), do: ord?(l, [r])
  def ord?(l, r) when is_integer(l) and is_list(r), do: ord?([l], r)

  def parse(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(&String.split(&1, "\n"))
    |> Enum.map(fn pair ->
      pair |> Enum.map(&Code.eval_string/1) |> Enum.map(&elem(&1, 0)) |> List.to_tuple()
    end)
  end
end
