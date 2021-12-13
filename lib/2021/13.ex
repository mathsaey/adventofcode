import AOC

aoc 2021, 13 do
  def p1 do
    {dots, [fold | _]} = input_string() |> parse()
    fold |> fold(dots) |> MapSet.size()
  end

  def p2 do
    {dots, folds} = input_string() |> parse()
    folds |> Enum.reduce(dots, &fold/2) |> print()
  end

  def parse(string) do
    [dots, folds] = string |> String.trim() |> String.split("\n\n")
    {parse_dots(dots), parse_folds(folds)}
  end

  def parse_dots(string) do
    string
    |> String.split("\n")
    |> MapSet.new(fn str ->
      str |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    end)
  end

  def parse_folds(string) do
    string
    |> String.split("\n")
    |> Enum.map(fn <<"fold along ", c::binary-size(1), "=", rest::binary>> ->
      {if(c == "x", do: :horizontal, else: :vertical), String.to_integer(rest)}
    end)
  end

  def fold(line, dots, get, put) do
    move = dots |> Enum.filter(&(get.(&1) > line)) |> MapSet.new()
    dots = MapSet.difference(dots, move)
    move |> MapSet.new(&put.(&1, line - (get.(&1) - line))) |> MapSet.union(dots)
  end

  def fold({:vertical, line}, dots), do: fold(line, dots, &elem(&1, 1), &put_elem(&1, 1, &2))
  def fold({:horizontal, line}, dots), do: fold(line, dots, &elem(&1, 0), &put_elem(&1, 0, &2))

  def print(set) do
    {max_x, _} = Enum.max_by(set, &elem(&1, 0))
    {_, max_y} = Enum.max_by(set, &elem(&1, 1))
    Enum.map_join(0..max_y, "\n", fn y ->
      Enum.map_join(0..max_x, &if({&1, y} in set, do: "█", else: " "))
    end)
    |> IO.puts()
  end
end
