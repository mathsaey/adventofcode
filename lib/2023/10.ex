import AOC

aoc 2023, 10 do
  def p1(input), do: input |> to_grid() |> follow_loop() |> length() |> then(&(div(&1, 2) + 1))

  def p2(input) do
    {start, grid} = to_grid(input)
    loop = follow_loop({start, grid})
    {x_bounds, y_bounds} = loop_bounds(loop)

    crossings =
      loop
      |> Enum.concat([start])
      |> Enum.map(&{&1, grid[&1]})
      |> Enum.filter(fn {_, %{type: type}} -> type in [:vertical, :corner_bottom] end)
      |> Enum.map(fn {c, _} -> c end)
      |> MapSet.new()

    Enum.map(y_bounds, fn y ->
      for x <- x_bounds, reduce: {0, false} do
        {ctr, inside?} ->
          cond do
            {x, y} in crossings -> {ctr, not inside?}
            {x, y} in loop -> {ctr, inside?}
            inside? -> {ctr + 1, inside?}
            true -> {ctr, inside?}
          end
        end
    end)
    |> Enum.map(fn {ctr, _} -> ctr end)
    |> Enum.sum()
  end

  def loop_bounds(loop) do
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(loop, fn {x, _} -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(loop, fn {_, y} -> y end)
    {(min_x - 1)..(max_x + 1), min_y - 1..max_y + 1}
  end

  def follow_loop({start, grid}) do
    %{neighbours: [next, _]} = grid[start]

    {start, next}
    |> Stream.iterate(fn {prev, cur} ->
      %{neighbours: [n1, n2]} = grid[cur]
      {cur, if(n1 == prev, do: n2, else: n1)}
    end)
    |> Stream.map(fn {_, cur} -> cur end)
    |> Enum.take_while(&(&1 != start))
  end

  def to_grid(input) do
    input
    |> parse()
    |> Enum.reject(fn {_, tile} -> tile == "." end)
    |> Enum.map(fn
      {{x, y}, "|"} -> {{x, y}, %{type: :vertical, neighbours: [{x, y - 1}, {x, y + 1}]}}
      {{x, y}, "-"} -> {{x, y}, %{type: :horizontal, neighbours: [{x - 1, y}, {x + 1, y}]}}
      {{x, y}, "L"} -> {{x, y}, %{type: :corner_bottom, neighbours: [{x, y - 1}, {x + 1, y}]}}
      {{x, y}, "J"} -> {{x, y}, %{type: :corner_bottom, neighbours: [{x, y - 1}, {x - 1, y}]}}
      {{x, y}, "7"} -> {{x, y}, %{type: :corner_top, neighbours: [{x - 1, y}, {x, y + 1}]}}
      {{x, y}, "F"} -> {{x, y}, %{type: :corner_top, neighbours: [{x + 1, y}, {x, y + 1}]}}
      {{x, y}, "S"} -> {{x, y}, :start}
    end)
    |> Map.new()
    |> update_start()
  end

  def update_start(grid) do
    {{x, y}, :start} = Enum.find(grid, fn {_, tile} -> tile == :start end)

    neighbours =
      for nx <- (x - 1)..(x + 1),
          ny <- (y - 1)..(y + 1),
          not (nx == x and ny == y),
          {x, y} in (grid[{nx, ny}][:neighbours] || []) do
        {nx, ny}
      end

    start = cond do
      {x, y - 1} in neighbours and {x, y + 1} in neighbours ->
        %{type: :vertical, neighbours: neighbours}
      {x - 1, y} in neighbours and {x + 1, y - 1} in neighbours ->
        %{type: :horizontal, neighbours: neighbours}
      {x, y - 1} in neighbours and {x + 1, y} in neighbours ->
        %{type: :corner_bottom, neighbours: neighbours}
      {x, y - 1} in neighbours and {x - 1, y} in neighbours ->
        %{type: :corner_bottom, neighbours: neighbours}
      {x - 1, y} in neighbours and {x, y + 1} in neighbours ->
        %{type: :corner_top, neighbours: neighbours}
      {x + 1, y} in neighbours and {x, y + 1} in neighbours ->
        %{type: :corner_top, neighbours: neighbours}
    end
    {{x, y}, Map.put(grid, {x, y}, start)}
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {tile, x} -> {{x, y}, tile} end)
    end)
  end
end
