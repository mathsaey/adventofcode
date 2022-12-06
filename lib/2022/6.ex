import AOC

aoc 2022, 6 do
  def p1(input), do: find_idx(input, 4)
  def p2(input), do: find_idx(input, 14)

  def find_idx(input, window_size), do: find_idx(1, Qex.new(), input, window_size)

  def find_idx(i, q, <<c, r::binary>>, w) when i < w, do: find_idx(i + 1, Qex.push(q, c), r, w)

  def find_idx(i, q, <<c, r::binary>>, w) do
    q = Qex.push(q, c)
    if duplicates?(q) do
      {_, q} = Qex.pop!(q)
      find_idx(i + 1, q, r, w)
    else
      i
    end
  end

  def duplicates?(q) do
    !Enum.reduce_while(q, MapSet.new(), &if &1 in &2 do
      {:halt, false}
      else
      {:cont, MapSet.put(&2, &1)}
      end)
  end
end
