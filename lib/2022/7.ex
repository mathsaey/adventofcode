import AOC

aoc 2022, 7 do
  def p1(input) do
    input
    |> parse()
    |> Enum.filter(fn {_, s} -> s <= 100000 end)
    |> Enum.map(fn {_, s} -> s end)
    |> Enum.sum()
  end

  def p2(input) do
    sizes = parse(input)
    required = 30000000 - (70000000 - sizes[[]])

    sizes
    |> Enum.filter(fn {_, s} -> s >= required end)
    |> Enum.map(fn {_, s} -> s end)
    |> Enum.min()
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.reduce({nil, %{}}, &parse_line/2)
    |> then(fn {_, map} -> map end)
    |> Enum.to_list()
    |> Qex.new()
    |> to_size_map(%{})
  end

  def parse_line("$ cd /", {_, dirs}), do: {[], dirs}
  def parse_line("$ cd ..", {[_ | path], dirs}), do: {path, dirs}
  def parse_line(<<"$ cd ", name::binary>>, {path, dirs}), do: {[name | path], dirs}
  def parse_line(<<"$ ls">>, {path, dirs}), do: {path, Map.put(dirs, path, {[], []})}

  def parse_line(<<"dir ", name::binary>>, {path, dirs}) do
    {path, Map.update!(dirs, path, fn {dirs, files} -> {[[name | path] | dirs], files} end)}
  end

  def parse_line(file, {path, dirs}) do
    [size, name] = String.split(file)
    size = String.to_integer(size)
    {path, Map.update!(dirs, path, fn {dirs, files} -> {dirs, [{size, name} | files]} end)}
  end

  def to_size_map(worklist, normalized) do
    if Enum.empty?(worklist) do
      normalized
    else
      {dir = {path, {children, files}}, worklist} = Qex.pop!(worklist)
      if Enum.all?(children, &Map.has_key?(normalized, &1)) do
        files = Enum.reduce(files, 0, fn {size, _}, sum -> sum + size end)
        dirs = Enum.reduce(children, 0, fn name, sum -> sum + normalized[name] end)
        to_size_map(worklist, Map.put(normalized, path, dirs + files))
      else
        to_size_map(Qex.push(worklist, dir), normalized)
      end
    end
  end
end
