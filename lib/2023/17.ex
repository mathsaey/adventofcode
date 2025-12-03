import AOC

aoc 2023, 17 do
  def p1(input), do: input |> parse() |> find_path(&p1_line/2)
  def p2(input), do: input |> parse() |> find_path(&p2_line/2)

  def find_path(grid = {_, {_..max_x//_, _..max_y//_}}, line_fun) do
    [{0, 0, :v}, {0, 0, :h}]
    |> Enum.map(&{manhattan(&1, {max_x, max_y}), &1})
    |> Enum.reduce({Heap.min(), %{}}, fn el = {_, option}, {queue, cheapest_paths} ->
      {Heap.push(queue, el), Map.put(cheapest_paths, option, 0)}
    end)
    |> a_star(line_fun, {max_x, max_y}, grid)
  end

  def a_star({queue, cheapest_paths}, line_fun, goal, {grid, bounds}) do
    {{_, current = {x, y, _}}, queue} = Heap.split(queue)
    current_score = cheapest_paths[current]

    if {x, y} == goal do
      current_score
    else
      current
      |> options(bounds, line_fun)
      |> Enum.reduce({queue, cheapest_paths}, fn option, {queue, cheapest_paths} ->
        score = current_score + cost(current, option, grid)
        if not Map.has_key?(cheapest_paths, option) or score < cheapest_paths[option] do
          heuristic = score + manhattan(option, goal)
          {Heap.push(queue, {heuristic, option}), Map.put(cheapest_paths, option, score)}
        else
          {queue, cheapest_paths}
        end
      end)
      |> a_star(line_fun, goal, {grid, bounds})
    end
  end

  def options({x, y, :v}, {bounds, _}, line), do: x |> line.(bounds) |> Enum.map(&{&1, y, :h})
  def options({x, y, :h}, {_, bounds}, line), do: y |> line.(bounds) |> Enum.map(&{x, &1, :v})

  def p1_line(i, min..max//_), do: for(j <- i - 3..i + 3, j != i, j >= min, j <= max, do: j)

  def p2_line(i, min..max//_) do
    Enum.concat(
      for(j <- i + 4..i + 10, j <= max, do: j),
      for(j <- i - 10..i - 4, j >= min, do: j)
    )
  end

  def cost({x_from, y_from, _}, {x_to, y_to, _}, grid) do
    for x <- x_from..x_to, y <- y_from..y_to, not (x == x_from and y == y_from), reduce: 0 do
      sum -> sum + grid[{x, y}]
    end
  end

  def manhattan({x, y, _}, {goal_x, goal_y}), do: abs(goal_x - x) + abs(goal_y - y)

  def parse(input), do: input |> Utils.Grid.input_to_map_with_bounds(&String.to_integer/1)
end
