import AOC

aoc 2021, 20 do
  def p1, do: input_string() |> solve(2)
  def p2, do: input_string() |> solve(50)

  def input_string, do: super() |> String.trim()

  def solve(str, n) do
    {iea, img} = parse(str)
    img
    |> Stream.iterate(&enhance(&1, iea))
    |> Stream.take(n + 1)
    |> Enum.to_list()
    |> List.last()
    |> Map.get(:others)
    |> MapSet.size()
  end

  def enhance(img = %{default: prev_default, others: set}, iea) do
    new_default = if(prev_default, do: 511 in iea, else: 0 in iea)

    set
    |> candidates()
    |> Enum.map(&{&1, enhance_coord(&1, img, iea)})
    |> Enum.filter(&(elem(&1, 1) != new_default))
    |> MapSet.new(&elem(&1, 0))
    |> then(&%{default: new_default, others: &1})
  end

  def candidates(set), do: set |> Enum.flat_map(&square/1) |> MapSet.new()

  def enhance_coord(c, img, iea), do: c |> coord_to_idx(img) |> then(&(&1 in iea))

  def coord_to_idx(c, %{default: d, others: set}) do
    c
    |> square()
    |> Enum.map(&if(&1 in set, do: not d, else: d))
    |> Enum.map(&if(&1, do: 1, else: 0))
    |> Integer.undigits(2)
  end

  def square({x, y}), do: for y <- y-1..y+1, x <- x-1..x+1, do: {x, y}

  def parse(string) do
    [iea, img] = String.split(string, "\n\n")
    {parse_iea(iea), %{default: false, others: parse_img(img)}}
  end

  def parse_img(img) do
    img
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {str, y} ->
      str
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {c, _} -> c == "#" end)
      |> Enum.map(fn {_, x} -> {x, y} end)
    end)
    |> MapSet.new()
  end

  def parse_iea(str) do
    str
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {c, _} -> c == "#" end)
    |> MapSet.new(&elem(&1, 1))
  end
end
