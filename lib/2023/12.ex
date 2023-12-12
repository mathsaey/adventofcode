import AOC

aoc 2023, 12 do
  def p1(input), do: input |> parse() |> Enum.map(&combos/1) |> Enum.sum()
  def p2(input), do: input |> parse() |> Enum.map(&unfold/1) |> Enum.map(&combos/1) |> Enum.sum()

  def combos({str, groups}), do: combos(str, false, groups)

  def combos(<<>>, ctr, []) when ctr == 0 or ctr == false, do: 1
  def combos(<<>>, _, _), do: 0

  def combos(<<".", rem::binary>>, false, groups), do: combos(rem, false, groups)
  def combos(<<".", rem::binary>>, 0, groups), do: combos(rem, false, groups)
  def combos(<<".", _::binary>>, _, _), do: 0

  def combos(<<"#", _::binary>>, false, []), do: 0
  def combos(<<"#", _::binary>>, 0, _), do: 0
  def combos(<<"#", rem::binary>>, false, [hd | tl]), do: combos(rem, hd - 1, tl)
  def combos(<<"#", rem::binary>>, n, groups), do: combos(rem, n - 1, groups)

  def combos(<<"?", rem::binary>>, ctr, groups) do
    memoized_combos("." <> rem, ctr, groups) + memoized_combos("#" <> rem, ctr, groups)
  end

  def memoized_combos(str, ctr, groups) do
    if v = Process.get({str, ctr, groups}) do
      v
    else
      v = combos(str, ctr, groups)
      Process.put({str, ctr, groups}, v)
      v
    end
  end

  def unfold({str, groups}) do
    {
      str |> List.duplicate(5) |> Enum.intersperse("?") |> Enum.into(""),
      groups |> List.duplicate(5) |> List.flatten()
    }
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      [record, checksum] = String.split(line)
      {
        record,
        checksum |> String.split(",") |> Enum.map(&String.to_integer/1)
      }
    end)
  end
end
