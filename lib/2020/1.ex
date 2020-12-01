import AOC

aoc 2020, 1 do
  def p1 do
    input = input_stream() |> Stream.map(&String.to_integer/1) |> Enum.to_list()
    tups = eat(input, tl(input))

    tups
    |> Enum.map(fn {l, r} -> {l, r, l + r} end)
    |> Enum.filter(&match?({_, _, 2020}, &1))
    |> Enum.map(fn {l, r, _} -> l * r end)
    |> hd()
  end

  def p2 do
    input = input_stream() |> Stream.map(&String.to_integer/1) |> Enum.to_list()
    tups = eat(input, tl(input), tl(tl(input)))

    tups
    |> Enum.map(fn {l, m, r} -> {l, m, r, l + m + r} end)
    |> Enum.filter(&match?({_, _, _, 2020}, &1))
    |> Enum.map(fn {l, m, r, _} -> l * m * r end)
    |> hd()
  end

  def eat([_, f2 | ft], []), do: eat([f2 | ft], ft)
  def eat(fl = [fh | _], [sh | st]), do: [{fh, sh} | eat(fl, st)]
  def eat(_, _), do: []

  def eat([_, fh1, fh2 | ft], [_], []), do: eat([fh1, fh2 | ft], [fh2 | ft], ft)
  def eat(fl, [_, sh | st], []), do: eat(fl, [sh | st], st)
  def eat(fl = [fh | _], sl = [sh | _], [th | tt]), do: [{fh, sh, th} | eat(fl, sl, tt)]
  def eat(_, _, _), do: []
end
