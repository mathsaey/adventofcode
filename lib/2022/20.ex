import AOC

aoc 2022, 20 do
  def p1(input) do
    input |> parse() |> Enum.with_index() |> mix() |> Enum.map(&elem(&1, 0)) |> get_coords()
  end

  def p2(input) do
    lst = input |> parse() |> Enum.map(&(&1 * 811589153)) |> Enum.with_index()
    1..10 |> Enum.reduce(lst, fn _, lst -> mix(lst) end) |> Enum.map(&elem(&1, 0)) |> get_coords()
  end

  def get_coords(lst) do
    lst
    |> Stream.cycle()
    |> Stream.drop_while(&(&1 != 0))
    |> Stream.chunk_every(1, 1000)
    |> Stream.drop(1)
    |> Enum.take(3)
    |> List.flatten()
    |> Enum.sum()
  end

  def mix(lst) do
    max = length(lst) - 1
    Enum.reduce(0..max, lst, &move(&2, &1, max))
  end

  def move(lst, old_idx, len) do
    {el, cur_idx} = find_idx_el(lst, old_idx)
    case el do
      0 ->
        lst
      el ->
        lst
        |> List.delete_at(cur_idx)
        |> List.insert_at(new_idx(el, cur_idx, len), {el, old_idx})
    end
  end

  def find_idx_el(lst, idx) do
    Enum.reduce_while(lst, 0, fn
      {el, o}, i -> if o == idx, do: {:halt, {el, i}}, else: {:cont, i + 1}
      _, i -> {:cont, i + 1}
    end)
  end

  def new_idx(0, cur, _), do: cur

  def new_idx(el, cur, len) do
    case rem(cur + el, len) do
      i when i <= 0 -> i - 1
      i -> i
    end
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end
end
