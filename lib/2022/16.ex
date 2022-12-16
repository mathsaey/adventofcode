import AOC

aoc 2022, 16 do
  def p1(input) do
    input |> parse() |> find_paths(30, 0, fn _, vent, prev -> prev + vent end) |> Enum.max()
  end

  def p2(input) do
    input
    |> parse()
    |> find_paths(26, {[], 0}, fn next, vent, {path, prev} -> {[next | path], prev + vent} end)
    |> Enum.map(fn {path, released} -> {MapSet.new(path), released} end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.map(fn {s, lst} -> {s, Enum.max(lst)} end)
    |> pairs()
    |> Stream.filter(fn {{ls, _}, {rs, _}} -> MapSet.disjoint?(ls, rs) end)
    |> Stream.map(fn {{_, l}, {_, r}} -> l + r end)
    |> Enum.max()
  end

  def find_paths(graph, time, init, res_fun) do
    merged = Map.merge(rates(graph), distances(graph))
    find_paths(:AA, time, valves_with_rate(graph), init, merged, res_fun)
  end

  def find_paths(_, _, [], res, _, _), do: [res]

  def find_paths(cur, time, to_visit, res, store, res_fun) do
    Enum.flat_map(to_visit, fn next ->
      dist = store[{cur, next}]
      time = time - dist - 1
      vent = store[next] * time

      if time > 0 do
        res = res_fun.(next, vent, res)
        find_paths(next, time, List.delete(to_visit, next), res, store, res_fun)
      else
        [res]
      end
    end)
  end

  def rates(graph) do
    graph
    |> valves_with_rate()
    |> Map.new(&{&1, Graph.vertex_labels(graph, &1)[:rate]})
  end

  def distances(graph) do
    graph
    |> valves_with_rate()
    |> Enum.concat([:AA])
    |> pairs()
    |> Enum.reduce(%{}, fn {f, t}, map ->
      weight = graph |> Graph.dijkstra(f, t) |> tl() |> Enum.count()
      Map.put(map, {f, t}, weight)
    end)
  end

  def pairs(lst), do: for(l <- lst, r <- lst, l != r, do: {l, r})

  def valves_with_rate(graph) do
    graph
    |> Graph.vertices()
    |> Stream.filter(&(Graph.vertex_labels(graph, &1)[:rate] > 0))
    |> Enum.to_list()
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
    |> Enum.reduce(Graph.new(type: :directed, vertex_identifier: &(&1)), fn valve, graph ->
      graph
      |> Graph.add_edges(Enum.map(valve["out"], &{valve["label"], &1}))
      |> Graph.label_vertex(valve["label"], label: valve["label"], rate: valve["rate"])
    end)
  end

  def parse_line(line) do
    ~r/Valve (?'label'\w+) has flow rate=(?'rate'\d+); tunnels? leads? to valves? (?'out'.*)/
    |> Regex.named_captures(line)
    |> Map.update!("rate", &String.to_integer/1)
    |> Map.update!("label", &String.to_atom/1)
    |> Map.update!("out", fn s -> s |> String.split(", ") |> Enum.map(&String.to_atom/1) end)
  end
end
