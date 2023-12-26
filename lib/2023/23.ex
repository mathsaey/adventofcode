import AOC

aoc 2023, 23 do
  def p1(input), do: solve(input, &Function.identity/1)
  def p2(input), do: solve(input, fn _ -> "." end)

  def solve(input, transform) do
    input
    |> parse()
    |> Enum.map(fn {k, v} -> {k, transform.(v)} end)
    |> Map.new()
    |> to_graph()
    |> collapse()
    |> all_path_lengths()
    |> Enum.max()
  end

  def all_path_lengths({graph, {start, stop}}) do
    all_path_lengths(start, graph, stop, 0, MapSet.new())
  end

  def all_path_lengths(current, _, dest, cost, _) when current == dest, do: [cost]
  def all_path_lengths(current, _, _, _, seen) when is_map_key(seen.map, current), do: []

  def all_path_lengths(current, graph, dest, cost, seen) do
    Enum.flat_map(graph[current], fn {next, path_cost} ->
      seen = MapSet.put(seen, current)
      all_path_lengths(next, graph, dest, cost + path_cost, seen)
    end)
  end

  def collapse({graph, {start, stop}}) do
    forks = all_forks(graph, start, stop)

    forks
    |> Enum.map(&{&1, paths_from_fork(&1, forks, graph)})
    |> Map.new()
    |> Map.delete(stop)
    |> then(&{&1, {start, stop}})
  end

  def all_forks(graph, start, stop) do
    graph
    |> Enum.reject(fn {_, neighbours} -> length(neighbours) <= 2 end)
    |> Enum.map(fn {coord, _} -> coord end)
    |> Enum.concat([start])
    |> Enum.concat([stop])
    |> MapSet.new()
  end

  def paths_from_fork(fork, forks, graph) do
    Enum.flat_map(graph[fork], &find_next_fork(&1, fork, 1, forks, graph))
  end

  def find_next_fork(cur, _, len, forks, _) when is_map_key(forks.map, cur), do: [{cur, len}]

  def find_next_fork(cur, prv, len, forks, graph) do
    case graph[cur] do
      [n] when n == prv -> []
      [n] when n != prv -> find_next_fork(n, cur, len + 1, forks, graph)
      [n1, n2] -> find_next_fork(if(prv == n1, do: n2, else: n1), cur, len + 1, forks, graph)
    end
  end

  def to_graph(grid) do
    grid
    |> Enum.map(fn t = {k, _} -> {k, neighbours(t, grid)} end)
    |> Map.new()
    |> then(fn graph -> {graph, bounds(graph)} end)
  end

  def bounds(graph) do
    {min_x, max_x} = graph |> Enum.map(fn {{x, _}, _} -> x end) |> Enum.min_max()
    {min_y, max_y} = graph |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.min_max()
    {{min_x, min_y}, {max_x, max_y}}
  end

  def neighbours({{x, y}, "<"}, _), do: [{x - 1, y}]
  def neighbours({{x, y}, ">"}, _), do: [{x + 1, y}]
  def neighbours({{x, y}, "v"}, _), do: [{x, y + 1}]
  def neighbours({{x, y}, "^"}, _), do: [{x, y - 1}]

  def neighbours({{x, y}, "."}, grid) do
    [{x + 1, y}, {x - 1, y}, {x, y - 1}, {x, y + 1}]
    |> Enum.reject(&(not Map.has_key?(grid, &1)))
  end

  def parse(input) do
    input
    |> Utils.Grid.input_to_map()
    |> Enum.reject(fn {_, v} -> v == "#" end)
  end
end
