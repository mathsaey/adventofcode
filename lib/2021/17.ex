import AOC

aoc 2021, 17 do
  def p1(input) do
    {_, y1.._} = parse(input)
    # We are looking for the highest possible throw => positive y, independent of chosen x
    # Ball falls with same velocity as going up.
    # Fastest fall speed => from 0 to y (bottom of target) in one step, otherwise we miss.
    # Downward speed during drop from 0 to y => -y
    # Downward speed during preceding step => -y - 1 => equal to upward velocity
    # Max height => upward velocity + upward velocity -1 + upward velocity -2 + ...
    # This is a triangular number, so we can calculate sum as (-y -1) + (-y -1 +1) / 2 (see
    # termial, day 7).
    div(y1 * (y1 + 1), 2)
  end

  def p2(input) do
    target = parse(input)
    target
    |> candidates()
    |> Stream.map(&path(&1, target))
    |> Stream.filter(&in?(&1, target))
    |> Enum.count()
  end

  def parse(string) do
    ~r/target area: x=(\d+)\.\.(\d+), y=(-?\d+)\.\.(-?\d+)/
    |> Regex.run(string, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [l, r] -> l..r end)
    |> List.to_tuple()
  end

  def candidates({x1..x2, y1.._}) do
    # We overshoot the target if we shoot faster than its furthest edge
    # We undershoot the target if we don't have enough speed to reach its closest edge.
    # max y -> speed from p1
    # min x -> calculate the minimum velocity we need to reach x1.
    #       => Solve v * v(v + 1) / 2 = x1
    # v * (v + 1) / 2 = x
    # v * (v + 1)     = 2x
    # v2 + v          = 2x
    # v2 + v + 1/4    = 2x + 1/4
    # (v + 1/2)^2     = 2x + 1/4
    # v + 1/2         = sqrt(2x + 1 /4)
    # v               = sqrt(2x + 1/4) - 1/2
    min_x = trunc(:math.sqrt(2 * x1 - 1/4) - 1/2)
    for x <- min_x..x2, y <- y1..(-y1 - 1), do: {x, y}
  end

  def path(v, target) do
    Stream.iterate({v, {0, 0}}, fn {{vx, vy}, {x, y}} ->
      {{if(vx == 0, do: vx, else: vx - 1), vy - 1}, {x + vx, y + vy}}
    end)
    |> Stream.map(&elem(&1, 1))
    |> Stream.take_while(&(not past?(&1, target)))
  end

  def in?({px, py}, {rx, ry}), do: px in rx and py in ry
  def in?(path, target), do: Enum.any?(path, &in?(&1, target))

  def past?({px, py}, {tx1..tx2, ty1..ty2}), do: px > max(tx1, tx2) or py < min(ty1, ty2)
end
