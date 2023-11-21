import AOC

aoc 2020, 12 do
  def p1(input), do: solve(input, {0, 0, 90}, &move_p1/2)
  def p2(input), do: solve(input, {{0, 0}, {10, 1}}, &move_p2/2)

  def solve(input, initial, move) do
    input |> parse() |> track(initial, move) |> manhattan_distance()
  end

  def parse(input), do: input |> String.split("\n") |> Enum.map(&parse_line/1)
  def parse_line(<<action, rest::binary>>), do: {action, String.to_integer(rest)}

  def manhattan_distance({e, n, _}), do: abs(e) + abs(n)
  def manhattan_distance({{e, n}, _}), do: abs(e) + abs(n)

  def track(input, initial, move), do: Enum.reduce(input, initial, &move.(&1, &2))

  def move_p1({?N, v}, {e, n, h}), do: {e, n + v, h}
  def move_p1({?S, v}, {e, n, h}), do: {e, n - v, h}
  def move_p1({?E, v}, {e, n, h}), do: {e + v, n, h}
  def move_p1({?W, v}, {e, n, h}), do: {e - v, n, h}
  def move_p1({?L, v}, {e, n, h}), do: {e, n, Integer.mod(h - v, 360)}
  def move_p1({?R, v}, {e, n, h}), do: {e, n, Integer.mod(h + v, 360)}
  def move_p1({?F, v}, {e, n, h}) when h <= 45 or h > 315, do: move_p1({?N, v}, {e, n, h})
  def move_p1({?F, v}, {e, n, h}) when h <= 135, do: move_p1({?E, v}, {e, n, h})
  def move_p1({?F, v}, {e, n, h}) when h <= 225, do: move_p1({?S, v}, {e, n, h})
  def move_p1({?F, v}, {e, n, h}) when h <= 315, do: move_p1({?W, v}, {e, n, h})

  def move_p2({?N, v}, {ship, {we, wn}}), do: {ship, {we, wn + v}}
  def move_p2({?S, v}, {ship, {we, wn}}), do: {ship, {we, wn - v}}
  def move_p2({?E, v}, {ship, {we, wn}}), do: {ship, {we + v, wn}}
  def move_p2({?W, v}, {ship, {we, wn}}), do: {ship, {we - v, wn}}
  def move_p2({?F, v}, {{se, sn}, {we, wn}}), do: {{se + v * we, sn + v * wn}, {we, wn}}
  def move_p2({?L, v}, state), do: move_p2({?R, 360 - v}, state)
  def move_p2({?R, 90}, {ship, {we, wn}}), do: {ship, {wn, - we}}
  def move_p2({?R, 180}, {ship, {we, wn}}), do: {ship, {-we, -wn}}
  def move_p2({?R, 270}, {ship, {we, wn}}), do: {ship, {-wn, we}}
end
