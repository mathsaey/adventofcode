import AOC

aoc 2018, 2 do
  def p1 do
    {twos, threes} =
      input()
      |> Stream.map(&String.codepoints/1)
      |> Stream.map(&counts/1)
      |> Stream.map(fn map -> {check_amount(map, 2), check_amount(map, 3)} end)
      |> Enum.reduce({0,0}, &acc_counts/2)
    twos * threes
  end

  def p2 do
    s = input()
    r = s
    |> Stream.map(fn el -> {el, all_diffs(el, s)} end)
    |> Stream.reject(fn {_, lst} -> lst == [] end)
    |> Enum.to_list()
    [{s1, [1]}, {s2, [1]}] = r
    remove_diff(s1, s2)
  end

  defp counts(lst) do
    Enum.reduce(lst, Map.new(), fn
      el, map -> Map.update(map, el, 1, &(&1 + 1))
    end)
  end

  defp check_amount(map, amount) do
    Enum.any?(Map.keys(map), fn key -> Map.get(map, key) == amount end)
  end

  defp acc_counts({true, true}, {twos, threes}), do: {twos + 1, threes + 1}
  defp acc_counts({true, false}, {twos, threes}), do: {twos + 1, threes}
  defp acc_counts({false, true}, {twos, threes}), do: {twos, threes + 1}
  defp acc_counts({false, false}, {twos, threes}), do: {twos, threes}

  defp all_diffs(line, stream) do
    stream
    |> Stream.map(&diff(line, &1))
    |> Stream.filter(fn el -> el == 1 end)
    |> Enum.to_list()
  end

  defp diff("",""), do: 0

  defp diff(s1,s2) do
    {h1, t1} = String.split_at(s1, 1)
    {h2, t2} = String.split_at(s2, 1)

    if h1 == h2 do
      diff(t1, t2)
    else
      1 + diff(t1, t2)
    end
  end

  defp remove_diff("", ""), do: ""
  defp remove_diff(s1, s2) do
    {h1, t1} = String.split_at(s1, 1)
    {h2, t2} = String.split_at(s2, 1)

    if h1 == h2 do
      h1 <> remove_diff(t1, t2)
    else
      t1
    end
  end
end
