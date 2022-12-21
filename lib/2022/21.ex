import AOC

aoc 2022, 21 do
  def p1(input), do: input |> parse() |> eval()

  def p2(input) do
    graph = parse(input)
    {humn, other} = split(graph, "root")
    answer = eval(other)

    path = graph |> Graph.get_shortest_path("humn", "root") |> Enum.reverse()

    humn
    |> Graph.add_vertex("root", {"root", answer})
    |> Graph.delete_vertex("humn")
    |> reverse_path(path)
    |> eval()
  end

  def split(graph, root) do
    graph
    |> Graph.delete_vertex(root)
    |> Graph.components()
    |> Enum.split_with(&("humn" in &1))
    |> Tuple.to_list()
    |> Enum.map(fn [vs] -> Graph.subgraph(graph, vs) end)
    |> List.to_tuple()
  end

  def reverse_path(graph, path) do
    path
    |> Enum.chunk_every(3,1, :discard)
    |> Enum.reduce(graph, fn [from, to, next], graph ->
      [op] = Graph.vertex_labels(graph, to)

      graph
      |> Graph.add_edge(from, to)
      |> Graph.delete_edge(to, from)
      |> Graph.remove_vertex_labels(to)
      |> Graph.label_vertex(to, replace_equation(op, from, next))
    end)
  end

  def replace_equation({next, :+, other}, from, next), do: {from, :-, other}
  def replace_equation({other, :+, next}, from, next), do: {from, :-, other}
  def replace_equation({next, :-, other}, from, next), do: {other, :+, from}
  def replace_equation({other, :-, next}, from, next), do: {other, :-, from}
  def replace_equation({next, :*, other}, from, next), do: {from, :/, other}
  def replace_equation({other, :*, next}, from, next), do: {from, :/, other}
  def replace_equation({next, :/, other}, from, next), do: {from, :*, other}
  def replace_equation({other, :/, next}, from, next), do: {other, :/, from}

  def eval(graph) do
    order = Graph.topsort(graph)
    root = List.last(order)
    Enum.reduce(order, %{}, &eval(graph, &1, &2))[root]
  end

  def eval(graph, label, prev) do
    res = case Graph.vertex_labels(graph, label) do
      [{l, op, r}] -> exec(op, prev[l], prev[r])
      [{_, n}] -> n
    end
    Map.put(prev, label, res)
  end

  def exec(:+, l, r), do: l + r
  def exec(:-, l, r), do: l - r
  def exec(:*, l, r), do: l * r
  def exec(:/, l, r), do: div(l, r)

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.reduce(Graph.new(), fn line, graph ->
      ~r/(\w+): (?:(\d+)|(\w+) (\+|\-|\*|\/) (\w+))/
      |> Regex.run(line, capture: :all_but_first)
      |> case do
        [label, "", left, op, right] ->
          graph
          |> Graph.add_edge(left, label)
          |> Graph.add_edge(right, label)
          |> Graph.label_vertex(label, {left, String.to_existing_atom(op), right})
        [label, n] ->
          graph
          |> Graph.add_vertex(label)
          |> Graph.label_vertex(label, {label, String.to_integer(n)})
      end
    end)
  end
end
