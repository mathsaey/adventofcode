import AOC

aoc 2023, 6 do
  def p1(input) do
    input
    |> parse()
    |> Enum.map(&winning_combinations/1)
    |> Enum.product()
  end

  def p2(input) do
    input
    |> parse()
    |> Enum.unzip()
    |> Tuple.to_list()
    |> Enum.map(&merge_numbers/1)
    |> List.to_tuple()
    |> winning_combinations()
  end

  def merge_numbers(lst), do: lst |> Enum.flat_map(&Integer.digits/1) |> Integer.undigits()

  def winning_combinations({time, distance}) do
    1..(time - 1)
    |> Enum.map(&distance(&1, time))
    |> Enum.count(& &1 > distance)
  end

  def distance(time, duration), do: (duration - time) * time

  def parse(input) do
    [t, d] = String.split(input, "\n")
    t = t |> String.trim_leading("Time:") |> String.split() |> Enum.map(&String.to_integer/1)
    d = d |> String.trim_leading("Distance:") |> String.split() |> Enum.map(&String.to_integer/1)
    Enum.zip(t, d)
  end
end
