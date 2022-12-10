import AOC

aoc 2022, 10 do
  def p1(input) do
    input
    |> x_values(1)
    |> Enum.drop(19)
    |> Enum.chunk_every(40)
    |> Enum.map(&hd/1)
    |> Enum.map(fn {x, c} -> x * c end)
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> x_values(0)
    |> Enum.map(fn {x, pix} -> {x, rem(pix, 40)} end)
    |> Enum.map(fn {x, pix} -> pix in sprite_range(x) end)
    |> Enum.chunk_every(40)
    |> Enum.take(6)
    |> draw()
  end

  def x_values(input, idx) do
    input
    |> parse()
    |> Enum.flat_map(&expand/1)
    |> Enum.scan(1, &exec/2)
    |> then(&[1 | &1])
    |> Enum.with_index(idx)
  end

  def draw(lst) do
    for row <- lst do
      for px <- row, do: IO.write(if px, do: "█", else: " ")
      IO.write("\n")
    end
  end

  def parse(input), do: input |> String.split("\n") |> Enum.map(&parse_line/1)
  def parse_line(<<"addx ", val::binary>>), do: {:addx, String.to_integer(val)}
  def parse_line("noop"), do: :noop

  def expand(:noop), do: [:noop]
  def expand({:addx, val}), do: [:noop, {:addx, val}]

  def exec(:noop, x), do: x
  def exec({:addx, n}, x), do: n + x

  def sprite_range(x), do: (x - 1)..(x + 1)
end
