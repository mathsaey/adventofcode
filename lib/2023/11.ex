import AOC

aoc 2023, 11 do
  def p1(input), do: solve(input, 1)
  def p2(input), do: solve(input, 999_999)

  def solve(input, to_add) do
    input |> parse() |> expand(to_add) |> pairs() |> Enum.map(&distance/1) |> Enum.sum()
  end

  def distance({{lx, ly}, {rx, ry}}), do: abs(lx - rx) + abs(ly - ry)

  def pairs([hd | tl]), do: Enum.map(tl, &{hd, &1}) ++ pairs(tl)
  def pairs([]), do: []

  def expand(galaxies, to_add), do: galaxies |> expand(0, to_add) |> expand(1, to_add)

  def expand(galaxies, idx, to_add) do
    galaxies
    |> find_empty(idx)
    |> Enum.with_index(0)
    |> Enum.map(fn {to_expand, idx} -> to_expand + idx * to_add end)
    |> Enum.reduce(galaxies, fn expand, galaxies ->
        Enum.map(galaxies, fn tup ->
          prev = elem(tup, idx)
          if(prev > expand, do: put_elem(tup, idx, prev + to_add), else: tup)
        end)
      end)
  end

  def find_empty(galaxies, idx) do
    galaxies = galaxies |> Enum.map(&elem(&1, idx)) |> MapSet.new()
    {min, max} = Enum.min_max(galaxies)
    Enum.reject(min..max, &(&1 in galaxies))
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.flat_map(fn {e, x} -> if(e == ".", do: [], else: [{x, y}]) end)
    end)
  end
end
