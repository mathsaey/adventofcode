import AOC

aoc 2020, 10 do
  def p1(input) do
    %{1 => f_1, 3 => f_3} = diffs(input) |> Enum.concat([3]) |> Enum.frequencies()
    f_1 * f_3
  end

  def p2(input), do: count(diffs(input)) + 1

  def diffs(input) do
    input
    |> String.split("\n")
    |> Stream.map(&String.to_integer/1)
    |> Enum.sort()
    |> Enum.map_reduce(0, &{&1 - &2, &1})
    |> elem(0)
  end

  # Start from the list of differences of the longest possible combination. A new combination is
  # possible if you can "collapse" two differences into one. Recursively count all possible
  # variants of the original list and the modified one.
  # A lot of work is done multiple times, so we memoise to offset this
  def count([l, r | tl]) when l + r <= 3, do: 1 + memoised([l + r | tl]) + memoised([r | tl])
  def count([_ | tl]), do: memoised(tl)
  def count([]), do: 0

  def memoised(args) do
    if res = Process.get(args) do
      res
    else
      res = count(args)
      Process.put(args, res)
      res
    end
  end
end
