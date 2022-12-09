import AOC

aoc 2022, 9 do
  def p1(input), do: solve(input, 1)
  def p2(input), do: solve(input, 9)

  def solve(input, idx) do
    input
    |> String.split("\n")
    |> Enum.map(&read/1)
    |> Enum.flat_map(fn {dir, count} -> List.duplicate(dir, count) end)
    |> Enum.scan({0, 0}, &move_head/2)
    |> Stream.iterate(fn prev -> Enum.scan(prev, {0, 0}, &move_tail/2) end)
    |> Enum.at(idx)
    |> Enum.uniq()
    |> Enum.count()
  end

  def read(<<dir::binary-size(1), " ", count::binary>>), do: {dir, String.to_integer(count)}

  def move_head("R", {x, y}), do: {x + 1, y}
  def move_head("L", {x, y}), do: {x - 1, y}
  def move_head("U", {x, y}), do: {x, y + 1}
  def move_head("D", {x, y}), do: {x, y - 1}

  def move_tail(h, t), do: if(adjacent?(h, t), do: t, else: do_move_tail(h, t))
  def adjacent?({hx, hy}, {tx, ty}), do: tx in (hx - 1)..(hx + 1) and ty in (hy - 1)..(hy + 1)

  def do_move_tail(h = {hx, hy}, t = {tx, ty}) do
    if hx == tx or hy == ty do
      h |> vert_horiz_moves() |> Enum.find(&adjacent?(t, &1))
    else
      t |> diag_moves() |> Enum.find(&adjacent?(h, &1))
    end
  end

  def vert_horiz_moves({x, y}), do: [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
  def diag_moves({x, y}), do: [{x - 1, y + 1}, {x + 1, y + 1}, {x - 1, y - 1}, {x + 1, y - 1}]
end
