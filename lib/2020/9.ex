import AOC

aoc 2020, 9 do

  def p1(input), do: find_not_sum(input)

  def p2(input) do
    {min, max} = longest_sum_min_max(input)
    min + max
  end

  def parse(input), do: input |> String.split("\n") |> Stream.map(&String.to_integer/1)

  def find_not_sum(input) do
    prev = input |> parse() |> Stream.take(25) |> Enum.to_list()

    input
    |> parse()
    |> Stream.drop(25)
    |> Stream.transform(prev, &{if(&1 in sums(&2), do: [], else: [&1]), tl(&2) ++ [&1]})
    |> Enum.to_list()
    |> hd()
  end

  def sums(candidates), do: for(l <- candidates, r <- candidates, l != r, uniq: true, do: l + r)

  def longest_sum_min_max(input) do
    target = find_not_sum(input)

    input
    |> parse()
    |> Stream.transform(parse(input), fn
      ^target, _ -> {:halt, nil}
      _, s -> {if(s = maybe_sum(s, target), do: [s], else: []), Stream.drop(s, 1)}
    end)
    |> Enum.max_by(&elem(&1, 1))
    |> elem(0)
    |> Enum.min_max()
  end

  def maybe_sum(stream, target) do
    Enum.reduce_while(stream, {[], 0}, fn el, {lst, len} ->
      sum = Enum.sum(lst) + el

      cond do
        sum > target -> {:halt, false}
        sum == target -> {:halt, {[el | lst], len + 1}}
        sum < target -> {:cont, {[el | lst], len + 1}}
      end
    end)
  end
end
