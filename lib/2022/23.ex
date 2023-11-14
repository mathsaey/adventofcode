import AOC

aoc 2022, 23 do
  def p1(input), do: input |> simulate() |> Stream.drop(10) |> Enum.at(0) |> score()

  def p2(input) do
    input
    |> simulate()
    |> Stream.map(&elem(&1, 0))
    |> Stream.chunk_every(2, 1)
    |> Stream.take_while(fn [l, r] -> l != r end)
    |> Enum.count()
    |> then(&(&1 + 1))
  end

  @dirs [:north, :south, :west, :east]
  def simulate(input), do: input |> parse() |> then(&{&1, @dirs}) |> Stream.iterate(&propose/1)

  def score({set, _}) do
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(set, fn {x, _} -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(set, fn {_, y} -> y end)
    (max_x - min_x + 1) * (max_y - min_y + 1) - MapSet.size(set)
  end

  def propose({set, dirs}) do
    set
    |> Enum.filter(fn c -> c |> neighbours() |> Enum.any?(&(&1 in set)) end)
    |> Enum.map(&{&1, propose(&1, dirs, set)})
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
    |> Enum.flat_map(fn
      {dst, [src]} -> [{src, dst}]
      _ -> []
    end)
    |> Enum.reduce(set, fn {src, dst}, set -> set |> MapSet.delete(src) |> MapSet.put(dst) end)
    |> then(&{&1, next(dirs)})
  end

  def propose(coord, [], _), do: coord

  def propose(coord, [dir | tl], set) do
    nbs = neighbours_at(dir, coord)
    if Enum.any?(nbs, &(&1 in set)), do: propose(coord, tl, set), else: Enum.at(nbs, 1)
  end

  def next([hd | tl]), do: tl ++ [hd]

  def neighbours({x, y}) do
    for nx <- (x - 1)..(x + 1), ny <- (y - 1)..(y + 1), {nx, ny} != {x, y}, do: {nx, ny}
  end

  def neighbours_at(:north, {x, y}), do: for(x <- (x - 1)..(x + 1), do: {x, y - 1})
  def neighbours_at(:south, {x, y}), do: for(x <- (x - 1)..(x + 1), do: {x, y + 1})
  def neighbours_at(:west, {x, y}), do: for(y <- (y - 1)..(y + 1), do: {x - 1, y})
  def neighbours_at(:east, {x, y}), do: for(y <- (y - 1)..(y + 1), do: {x + 1, y})

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.filter(fn {c, _} -> c == "#" end)
      |> Enum.map(fn {_, x} -> {x, y} end)
    end)
    |> MapSet.new()
  end
end
