import AOC

aoc 2020, 9 do
  def input_stream, do: super() |> Stream.map(&String.to_integer/1)

  def p1, do: find_not_sum()

  def p2 do
    {min, max} = longest_sum_min_max()
    min + max
  end

  def find_not_sum() do
    prev = input_stream() |> Stream.take(25) |> Enum.to_list()

    input_stream()
    |> Stream.drop(25)
    |> Stream.transform(prev, &{if(&1 in sums(&2), do: [], else: [&1]), tl(&2) ++ [&1]})
    |> Enum.to_list()
    |> hd()
  end

  def sums(candidates), do: for(l <- candidates, r <- candidates, l != r, uniq: true, do: l + r)

  def longest_sum_min_max() do
    target = find_not_sum()

    input_stream()
    |> Stream.transform(input_stream(), fn
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
