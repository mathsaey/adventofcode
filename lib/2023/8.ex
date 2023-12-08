import AOC

aoc 2023, 8 do
  def p1(input) do
    input |> parse() |> path_from("AAA") |> Stream.take_while(&(&1 != "ZZZ")) |> steps()
  end

  def p2(input) do
    {path, map} = parse(input)
    map
    |> Map.keys()
    |> Enum.filter(fn <<_, _, l>> -> l == ?A end)
    |> Enum.map(&path_from({path, map}, &1))
    |> Enum.map(&Stream.take_while(&1, fn <<_, _, l>> -> l != ?Z end))
    |> Enum.map(&steps/1)
    |> Enum.reduce(&lcd/2)
  end

  def lcd(a, b), do: div(a * b, Integer.gcd(a, b))
  def steps(stream), do: Enum.count(stream) + 1

  def path_from({path, map}, start) do
    path
    |> Stream.cycle()
    |> Stream.scan(start, fn direction, location -> elem(map[location], direction) end)
  end

  def parse(input) do
    [instructions, nodes] = String.split(input, "\n\n")
    instructions = instructions |> String.graphemes() |> Enum.map(fn "L" -> 0 ; "R" -> 1 end)
    {instructions, parse_nodes(nodes)}
  end

  def parse_nodes(nodes) do
    nodes |> String.split("\n") |> Enum.map(&parse_node/1) |> Map.new()
  end

  def parse_node(node) do
    ~r/(\w{3}) = \((\w{3}), (\w{3})\)/
    |> Regex.run(node)
    |> then(fn [_, name, l, r] -> {name, {l, r}} end)
  end
end
