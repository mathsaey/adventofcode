import AOC

aoc 2021, 23 do
  @hallway for x <- 0..10, do: {x, 0}
  @room_xs 2..8//2

  @hallway_spots Enum.reject(@hallway, fn {x, _} -> x in @room_xs end)

  def p1(input), do: input |> parse() |> solve()

  def p2(input) do
    [top, hallway, room_top, room, bot] = String.split(input, "\n")
    [top, hallway, room_top, "  #D#C#B#A#", "  #D#B#A#C#", room, bot]
    |> Enum.join("\n")
    |> parse()
    |> solve()
  end

  def solve(initial_state) do
    a_star({Heap.new() |> Heap.push({0, initial_state}), %{initial_state => 0}})
  end

  def a_star({open, g_scores}) do
    {{_, current}, open} = Heap.split(open)
    current_cost = g_scores[current]

    if goal_state?(current) do
      current_cost
    else
      current
      |> valid_moves()
      |> Enum.map(&{move(current, &1), current_cost + cost(&1)})
      |> Enum.reduce({open, g_scores}, &a_star_grade_state/2)
      |> a_star()
    end
  end

  def a_star_grade_state({new_state, cost}, {open, g_scores}) do
    if not Map.has_key?(g_scores, new_state) or cost < g_scores[new_state] do
      h_score = cost + lowest_possible_goal_cost(new_state)
      {Heap.push(open, {h_score, new_state}), Map.put(g_scores, new_state, cost)}
    else
      {open, g_scores}
    end
  end

  def lowest_possible_goal_cost({map, _}) do
    map
    |> Enum.filter(&in_hallway?/1)
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Enum.map(fn {c, p} -> {c, {x(p), 1}, p} end)
    |> Enum.map(&cost/1)
    |> Enum.sum()
  end

  def goal_state?({state, _}) do
    state
    |> Enum.any?(fn
      {{_, 0}, pod} when not is_nil(pod) -> true
      {{x, y}, pod} when y > 0 -> pod && x != x(pod)
      _ -> false
    end)
    |> Kernel.not()
  end

  def move({state, max_y}, {{x_from, y_from}, {x_to, y_to}, p}) do
    state
    |> Map.put({x_from, y_from}, nil)
    |> Map.put({x_to, y_to}, p)
    |> then(&{&1, max_y})
  end

  def cost({from, to, :a}), do: moves(from, to)
  def cost({from, to, :b}), do: moves(from, to) * 10
  def cost({from, to, :c}), do: moves(from, to) * 100
  def cost({from, to, :d}), do: moves(from, to) * 1000

  def moves({x_from, y_from}, {x_to, y_to}), do: abs(x_from - x_to) + abs(y_from - y_to)

  def valid_moves(state = {map, _}) do
    {hallway_pods, room_pods} =
      map
      |> Enum.reject(fn {_, v} -> is_nil(v) end)
      |> Enum.reject(&in_final_position?(state, &1))
      |> Enum.split_with(&in_hallway?/1)

    Enum.concat(
      Enum.map(hallway_pods, fn {c, p} -> {c, final_pos(state, p), p} end),
      Enum.flat_map(room_pods, fn {c, p} -> Enum.map(@hallway_spots, &{c, &1, p}) end)
    )
    |> Enum.filter(&has_path?(state, &1))
  end

  def has_path?(state, {start, stop, _}), do: path(state, start, stop) |> Enum.all?(&is_nil/1)

  def final_pos({state, max_y}, p), do: {x(p), Enum.find(max_y..1, &(state[{x(p), &1}] != p))}

  def in_final_position?(_, {{_, 0}, _}), do: false
  def in_final_position?({state, max_y}, {{x, y}, pod}) do
    x(pod) == x and Enum.all?(y..max_y, &(state[{x, &1}] == pod))
  end

  def in_hallway?({{_, y}, _}), do: y == 0

  def path({state, _}, {x_from, y_from}, {x_to, y_to}) do
    Enum.concat(
      for(x <- x_from..x_to, do: {x, 0}),
      for(y <- y_from..y_to, do: {if(y_from > y_to, do: x_from, else: x_to), y})
    )
    |> List.delete({x_from, y_from})
    |> Enum.map(&state[&1])
  end

  def x(:a), do: 2
  def x(:b), do: 4
  def x(:c), do: 6
  def x(:d), do: 8

  def parse(str) do
    ~r/..#([[:upper:]])#([[:upper:]])#([[:upper:]])#([[:upper:]])#/
    |> Regex.scan(str, capture: :all_but_first)
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {line, y} ->
      line
      |> Enum.map(&String.downcase/1)
      |> Enum.map(&String.to_atom/1)
      |> Enum.zip(@room_xs)
      |> Enum.map(fn {p, x} -> {{x, y}, p} end)
    end)
    |> Enum.concat(Enum.map(@hallway, &{&1, nil}))
    |> Map.new()
    |> then(fn s -> {s, s |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()} end)
  end
end
