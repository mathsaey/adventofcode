import AOC

aoc 2018, 3 do
  defmodule M do
    def new() do
      Map.new()
    end

    def get(m, i, j) do
      Map.get(m, {i,j}, [])
    end

    def claim(m, id, l, t, w, h) do
      (l .. l + w - 1)
      |> Stream.flat_map(fn i -> Enum.map(t .. t + h - 1, fn j -> {i, j} end) end)
      |> Enum.reduce(m, fn {i, j}, m -> claim(m, id, i, j) end)
    end

    def claim(m, id, i, j) do
      Map.update(m, {i,j}, [id], &([id | &1]))
    end
  end

  def claims do
    input()
    |> Stream.map(&Regex.scan(~r/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/, &1))
    |> Stream.map(&tl(hd(&1)))
    |> Stream.map(fn line -> Enum.map(line, &String.to_integer/1) end)
    |> Enum.reduce(M.new(), fn [id, l, t, w, h], m -> M.claim(m, id, l, t, w, h) end)
    |> Map.values()
  end

  def p1 do
    claims()
    |> Enum.filter(&(length(&1) > 1))
    |> length()
  end

  def p2 do
    ids = Enum.reduce(
      claims(),
      MapSet.new(),
      fn ids, set -> Enum.reduce(ids, set, &MapSet.put(&2, &1)) end
    )

    res = Enum.reduce(claims(), ids, fn
      [], set -> set
      [_], set -> set
      lst, set -> Enum.reduce(lst, set, &MapSet.delete(&2, &1))
    end)
    res |> MapSet.to_list() |> hd()
  end
end
