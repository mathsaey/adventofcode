import AOC

aoc 2022, 3 do
  def p1(input) do
    input
    |> String.split("\n")
    |> Enum.map(&split/1)
    |> Enum.map(&duplicate_item/1)
    |> Enum.map(&priority/1)
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> String.split("\n")
    |> Enum.map(&to_charlist/1)
    |> Enum.map(&MapSet.new/1)
    |> Enum.chunk_every(3)
    |> Enum.map(fn lst -> Enum.reduce(lst, &MapSet.intersection/2) end)
    |> Enum.map(&Enum.to_list/1)
    |> Enum.map(&hd/1)
    |> Enum.map(&priority/1)
    |> Enum.sum()
  end

  def duplicate_item({l, r}) do
    l = l |> to_charlist() |> MapSet.new()
    r = r |> to_charlist() |> MapSet.new()
    MapSet.intersection(l, r) |> Enum.to_list() |> hd()
  end

  def split(items) do
    half = items |> byte_size |> div(2)
    <<l::binary-size(half), r::binary-size(half)>> = items
    {l, r}
  end

  def priority(i) when i in ?a..?z, do: i - ?a + 1
  def priority(i) when i in ?A..?Z, do: i - ?A + 27
end
