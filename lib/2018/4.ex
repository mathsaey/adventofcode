import AOC

aoc 2018, 4 do
  def get do
    input()
    |> Enum.sort()
    |> Stream.map(&Regex.scan(~r/\[1518-(\d\d)-(\d\d) (\d\d):(\d\d)\] (.*)/, &1))
    |> Stream.map(&tl(hd(&1)))
    |> Stream.map(&parse_line/1)
    |> Enum.reduce({-1, -1, %{}}, fn
      %{entry: {:guard, id}}, {_, _, m} -> {id, -1, m}
      %{entry: :sleep, minute: min}, {id, _, m} -> {id, min, m}
      %{entry: :wake, minute: min}, {id, start, m} ->
        m = Enum.reduce(
          start .. min - 1,
          m,
          &Map.update(&2, id, %{}, fn times -> Map.update(times, &1, 1, fn cur -> cur + 1 end) end))
        {id, -1, m}
    end)
    |> elem(2)
  end

  def parse_line([month, day, hour, minute, entry]) do
    %{
      entry: parse_entry(entry),
      month: String.to_integer(month),
      day: String.to_integer(day),
      hour: String.to_integer(hour),
      minute: String.to_integer(minute)
    }
  end

  def parse_entry("falls asleep"), do: :sleep
  def parse_entry("wakes up"), do: :wake

  def parse_entry(entry) do
    [[_, id]] = Regex.scan(~r/Guard #(\d+) begins shift/, entry)
    {:guard, String.to_integer(id)}
  end

  def p1 do
    id =
      get()
      |> Enum.map(fn {id, map} -> {id, Enum.sum(Map.values(map))} end)
      |> Enum.max_by(&elem(&1, 1))
      |> elem(0)
    min =
      get()[id]
      |> Enum.max_by(&elem(&1, 1))
      |> elem(0)
    id * min
  end

  def p2 do
    id =
      get()
      |> Enum.map(fn {id, map} -> {id, Enum.max_by(map, &elem(&1, 1))} end)
      |> Enum.max_by(fn {_, {_, x}} -> x end)
      |> elem(0)
    min =
      get()[id]
      |> Enum.max_by(&elem(&1, 1))
      |> elem(0)
    id * min
  end
end
