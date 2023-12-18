import AOC

aoc 2023, 18 do
  def p1(input), do: solve(input, &turning_points_p1/1)
  def p2(input), do: solve(input, &turning_points_p2/1)
  def solve(input, turning_points_fun), do: input |> parse() |> turning_points_fun.() |> picks()

  def turning_points_p1(instructions) do
    instructions
    |> Enum.scan({0, 0}, fn
      {:R, l, _}, {x, y} -> {x + l, y}
      {:L, l, _}, {x, y} -> {x - l, y}
      {:U, l, _}, {x, y} -> {x, y - l}
      {:D, l, _}, {x, y} -> {x, y + l}
    end)
  end

  def turning_points_p2(instructions) do
    instructions
    |> Enum.map(fn {_, _, <<"#", dist::binary-size(5), dir::binary-size(1)>>} ->
      {String.to_integer(dir), String.to_integer(dist, 16)}
    end)
    |> Enum.scan({0, 0}, fn
      {0, l}, {x, y} -> {x + l, y}
      {1, l}, {x, y} -> {x, y + l}
      {2, l}, {x, y} -> {x - l, y}
      {3, l}, {x, y} -> {x, y - l}
    end)
  end

  def boundary_points(turning_points) do
    turning_points
    |> Enum.chunk_every(2, 1, turning_points)
    |> Enum.map(fn
      [{lx, y}, {rx, y}] -> abs(lx - rx)
      [{x, ly}, {x, ry}] -> abs(ly - ry)
    end)
    |> Enum.sum()
  end

  def shoelace(turning_points) do
    turning_points
    |> Enum.chunk_every(2, 1, turning_points)
    |> Enum.map(fn [{lx, ly}, {rx, ry}] -> lx * ry - rx * ly end)
    |> Enum.sum()
    |> then(fn x -> div(abs(x), 2) end)
  end

  def picks(turning_points) do
    area = shoelace(turning_points)
    boundary_points = boundary_points(turning_points)
    area - div(boundary_points, 2) + 1 + boundary_points
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      [_, dir, dist, colour] = Regex.run(~r/(\w) (\d+) \((#\w{6})\)/, line)
      {String.to_atom(dir), String.to_integer(dist), colour}
    end)
  end
end
