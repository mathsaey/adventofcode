import AOC

aoc 2020, 23 do
  def input, do: input_string() |> String.to_integer() |> Integer.digits()

  def p1 do
    max = input() |> Enum.max()
    input() |> from_list() |> n_turns(100, max) |> to_list(1) |> tl() |> Integer.undigits()
  end

  def p2 do
    input = input()
    last = List.last(input)
    max = Enum.max(input)
    map = from_list(input)
    until = 1_000_000

    map =
      (max + 1)..until
      |> Enum.reduce(map, fn el, acc -> Map.put(acc, el, el + 1) end)
      |> Map.put(last, max + 1)
      |> Map.put(until, map.current)
      |> n_turns(10_000_000, until)

    e1 = Map.get(map, 1)
    e2 = Map.get(map, e1)
    e1 * e2
  end

  def n_turns(map, 0, _), do: map
  def n_turns(map, n, max), do: map |> turn(max) |> n_turns(n - 1, max)

  def turn(map, max), do: map |> pick_up() |> destination(max) |> move() |> next_current()

  def pick_up(map), do: {map, pick_up(map, Map.get(map, map.current), 3)}
  def pick_up(_, _, 0), do: []
  def pick_up(map, prev, n), do: [prev | pick_up(map, Map.get(map, prev), n - 1)]

  def destination({m = %{current: c}, pick_up}, max), do: destination({m, pick_up}, c - 1, max)

  def destination({map, pick_up}, dst, max) do
    cond do
      dst in pick_up -> destination({map, pick_up}, dst - 1, max)
      dst == 0 -> destination({map, pick_up}, max, max)
      true -> {map, pick_up, dst}
    end
  end

  def move({map, [e1, _, e3], dst}) do
    curr_succ = Map.get(map, e3)
    dst_succ = Map.get(map, dst)

    map
    |> Map.put(map.current, curr_succ)
    |> Map.put(e3, dst_succ)
    |> Map.put(dst, e1)
  end

  def next_current(map), do: %{map | current: Map.get(map, map.current)}

  def from_list(lst = [hd | _]) do
    last = List.last(lst)
    {_, m} = Enum.reduce(lst, {last, %{}}, fn el, {p, m} -> {el, Map.put(m, p, el)} end)
    Map.put(m, :current, hd)
  end

  def to_list(map), do: to_list(map, Map.get(map, :current))
  def to_list(map, curr), do: [curr | to_list(map, curr, Map.get(map, curr))]
  def to_list(_, curr, curr), do: []
  def to_list(map, curr, prev), do: [prev | to_list(map, curr, Map.get(map, prev))]
end
