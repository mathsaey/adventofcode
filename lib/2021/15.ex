import AOC

aoc 2021, 15 do
  def p1, do: input_stream() |> parse() |> solve()
  def p2, do: input_stream() |> parse() |> expand() |> solve()
  def solve(stream), do: stream |> to_grid() |> a_star() |> score()

  def parse(stream) do
    stream
    |> Stream.map(&String.to_integer/1)
    |> Stream.map(&Integer.digits/1)
  end

  def expand(stream) do
    width = Enum.take(stream, 1) |> hd() |> length()
    height = stream |> Enum.to_list() |> length()

    stream
    |> Stream.cycle()
    |> Stream.chunk_every(height)
    |> Stream.take(5)
    |> Stream.with_index()
    |> Stream.flat_map(fn {rows, idx} -> Enum.map(rows, &{&1, idx}) end)
    |> Stream.map(&expand_row(&1, width))
  end

  def expand_row({row, offset}, width) do
    row
    |> Stream.cycle()
    |> Stream.chunk_every(width)
    |> Stream.take(5)
    |> Stream.with_index(offset)
    |> Stream.flat_map(fn {lst, idx} ->
      lst |> Enum.map(&(&1 + idx)) |> Enum.map(&rem(&1 - 1, 9) + 1)
    end)
    |> Enum.to_list()
  end

  def to_grid(stream) do
    stream
    |> Stream.map(&Enum.with_index/1)
    |> Stream.with_index()
    |> Stream.flat_map(fn {lst, y} -> Enum.map(lst, fn {el, x} -> {{x, y}, el} end) end)
    |> Map.new()
    |> then(fn map -> {map, map |> Enum.max_by(&elem(&1, 0)) |> elem(0)} end)
  end

  @doc """
  A* search as described by wikipedia.

  https://en.wikipedia.org/wiki/A*_search_algorithm#Pseudocode

  Some notes:
  - A heap is used as a priority queue, this is notably faster than using a set, even without
    destructive updates.
  - We use the manhattan distance to the goal as heuristic
  """
  def a_star({map, goal}) do
    a_star({Heap.new() |> Heap.push({0, {0, 0}}), %{{0, 0} => 0}, %{}}, goal, map)
  end

  def a_star({open, g_scores, predecessors}, goal, map) do
    {{_, current}, open} = Heap.split(open)
    current_score = g_scores[current]

    if current == goal do
      {predecessors, map, goal}
    else
      current
      |> neighbours(goal)
      |> Enum.reduce(
        {open, g_scores, predecessors},
        &neighbour(&1, current, current_score, &2, map, goal)
      )
      |> a_star(goal, map)
    end
  end

  def neighbour(neighbour, current, current_score, {open, g_scores, predecessors}, map, goal) do
    score_from_current = map[neighbour] + current_score
    if not Map.has_key?(g_scores, neighbour) or score_from_current < g_scores[neighbour] do
      h_score = score_from_current + manhattan(neighbour, goal)
      {
        Heap.push(open, {h_score, neighbour}),
        Map.put(g_scores, neighbour, score_from_current),
        Map.put(predecessors, neighbour, current)
      }
    else
      {open, g_scores, predecessors}
    end
  end

  def manhattan({xs, ys}, {xg, yg}), do: (xg - xs) + (yg - ys)

  def neighbours({x, y}, {max_x, max_y}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Enum.reject(fn {x, y} -> x < 0 or y < 0 or x > max_x or y > max_y end)
  end

  @doc """
  Backtrack from goal to start and calculate score
  """
  def score({pred, map, goal}), do: score(pred, map, goal, 0)
  def score(_, _, {0, 0}, total), do: total
  def score(pred, map, cur, total), do: score(pred, map, pred[cur], total + map[cur])
end
