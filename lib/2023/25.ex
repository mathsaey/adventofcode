import AOC

aoc 2023, 25 do
  def p1(input) do
    graph = parse(input)
    connections = [{_, _} | _] = find_critical_connections(graph)

    graph
    |> Graph.delete_edges(connections)
    |> Graph.components()
    |> Enum.map(&length/1)
    |> Enum.product()
  end

  @samples 1000
  @critical_connections 3

  def find_critical_connections(graph) do
    graph
    |> sample_stream()
    |> Enum.take(@samples)
    |> Enum.flat_map(&Enum.chunk_every(&1, 2, 1, :discard))
    |> Enum.map(&Enum.sort/1)
    |> Enum.frequencies()
    |> Enum.sort_by(fn {_, v} -> v end, :desc)
    |> Enum.take(@critical_connections)
    |> Enum.map(fn {val, _} -> List.to_tuple(val) end)
  end

  def sample_stream(graph), do: [graph] |> Stream.cycle() |> Stream.map(&sample/1)
  def sample(graph), do: Graph.dijkstra(graph, random_vertex(graph), random_vertex(graph))
  def random_vertex(graph), do: graph |> Graph.vertices() |> Enum.random()

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      [node, edges] = String.split(line, ":")
      edges = edges |> String.split() |> Enum.map(&{node, &1})
      {node, edges}
    end)
    |> Enum.reduce(Graph.new(type: :undirected), fn {node, edges}, graph ->
      graph |> Graph.add_vertex(node) |> Graph.add_edges(edges)
    end)
  end
end
