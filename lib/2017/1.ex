defmodule Y2017.D1 do
  def p1(int) when is_integer(int), do: Integer.digits(int) |> p1() |> Enum.sum()

  def p1(lst), do: p1(lst, List.last(lst))

  def p1([], _), do: []

  def p1([hd | tl], prev) when hd == prev, do: [prev | p1(tl, hd)]
  def p1([hd | tl], _), do: p1(tl, hd)

  def p2(int) when is_integer(int), do: Integer.digits(int) |> p2() |> Enum.sum()

  def p2(lst), do: p2(lst, lst, 0)

  def p2(_, [], _), do: []

  def p2(lst, [hd | tl], idx) do
    len = length(lst)
    dst = idx + (len / 2) |> round
    dst = if dst >= len, do: dst - len, else: dst

    if Enum.at(lst, dst) == hd do
      [hd | p2(lst, tl, idx + 1)]
    else
      p2(lst, tl, idx + 1)
    end
  end
end
