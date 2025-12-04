import AOC

aoc 2025, 1 do
  def p1(input), do: input |> expand() |> Enum.count(fn {e, _} -> e == 0 end)

  def p2(input) do
    input
    |> expand()
    |> Enum.map(fn
      {0, n} -> n + 1
      {_, n} -> n
    end)
    |> Enum.sum()
  end

  def expand(input), do: input |> parse() |> Enum.scan({50, nil}, &rotate/2)

  def rotate({:left, i}, {state, _}) do
    case state - i do
      _ when state == 0 -> {Integer.mod(-i, 100), div(i, 100)}
      res when res >= 0 -> {res, 0}
      res when res < 0 and rem(res, 100) == 0 -> {Integer.mod(res, 100), abs(div(res, 100))}
      res when res < 0 -> {Integer.mod(res, 100), 1 + abs(div(res, 100))}
    end
  end

  def rotate({:right, i}, {state, _}) do
    case state + i do
      res when rem(res, 100) == 0 -> {0, div(res, 100) - 1}
      res -> {rem(res, 100), div(res, 100)}
    end
  end

  def parse(input) do
    input
    |> String.split()
    |> Enum.map(fn
      <<"L", int::binary>> -> {:left, String.to_integer(int)}
      <<"R", int::binary>> -> {:right, String.to_integer(int)}
    end)
  end
end
