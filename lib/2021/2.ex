import AOC

aoc 2021, 2 do
  def input_stream, do: super() |> Stream.map(&parse/1)

  def p1 do
    input_stream()
    |> Enum.reduce({0, 0}, fn
      {:forward, x}, {h, d} -> {h + x, d}
      {:down, x}, {h, d} -> {h, d + x}
      {:up, x}, {h, d} -> {h, d - x}
    end)
    |> then(fn {h, d} -> h * d end)
  end

  def p2 do
    input_stream()
    |> Enum.reduce({0, 0, 0}, fn
      {:forward, x}, {h, d, a} -> {h + x , d + a * x, a}
      {:down, x}, {h, d, a} -> {h, d, a + x}
      {:up, x}, {h, d, a} -> {h, d, a - x}
    end)
    |> then(fn {h, d, _} -> h * d end)
  end

  def parse(<<"forward ", num::binary>>), do: {:forward, String.to_integer(num)}
  def parse(<<"down ", num::binary>>), do: {:down, String.to_integer(num)}
  def parse(<<"up ", num::binary>>), do: {:up, String.to_integer(num)}
end
