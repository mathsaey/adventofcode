import AOC

aoc 2021, 22 do
  def p1(input) do
    input
    |> parse()
    |> Enum.filter(fn {_, ranges} ->
      Enum.all?(ranges, fn first..last//_ -> first in -50..50 and last in -50..50 end)
    end)
    |> solve()
  end

  def p2(input), do: input |> parse() |> solve()

  def solve(instructions) do
    instructions
    |> Enum.reduce([], fn {add?, chunk}, cubes ->
      cubes = Enum.flat_map(cubes, &remove(&1, chunk))
      if(add?, do: [chunk | cubes], else: cubes)
    end)
    |> Enum.map(&cubes_in/1)
    |> Enum.sum()
  end

  def remove(cube, chunk) do
    Enum.zip(cube, chunk)
    |> Enum.all?(fn {cb, ch} -> not Range.disjoint?(cb, ch) end)
    |> if(do: do_remove(cube, chunk), else: [cube])
  end

  def do_remove([], []), do: []

  def do_remove([cb_start..cb_end//_ | cb_tl], [ch_start..ch_end//_ | ch_tl]) do
    pre = cb_start..(ch_start - 1)//1
    post = (ch_end + 1)..cb_end//1

    do_remove(cb_tl, ch_tl)
    |> Enum.map(&[max(cb_start, ch_start)..min(cb_end, ch_end) | &1])
    |> Enum.concat(if(Enum.empty?(pre), do: [], else: [[pre | cb_tl]]))
    |> Enum.concat(if(Enum.empty?(post), do: [], else: [[post | cb_tl]]))
  end

  def cubes_in(cuboid), do: cuboid |> Enum.map(&Range.size/1) |> Enum.product()

  def parse(input), do: input |> String.split("\n") |> Enum.map(&parse_step/1)

  def parse_step(str) do
    [on_or_off, rest] = String.split(str, " ")

    ~r/x=(.+),y=(.+),z=(.+)/
    |> Regex.run(rest, capture: :all_but_first)
    |> Enum.map(&parse_range/1)
    |> then(&{on_or_off == "on", &1})
  end

  def parse_range(str) do
    ~r/(-?\d+)..(-?\d+)/
    |> Regex.run(str, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
    |> then(fn [l, r] -> l..r end)
  end
end
