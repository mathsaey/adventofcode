import AOC

aoc 2020, 25 do
  @magic_number 20201227

  def p1 do
    [card, door] = parse()
    card_loop_size = find_loop_size(card)
    priv_key(door, card_loop_size)
  end

  def find_loop_size(pub) do
    steps(7)
    |> Stream.with_index()
    |> Stream.drop_while(fn {v, _} -> v != pub end)
    |> Enum.take(1)
    |> hd()
    |> elem(1)
  end

  def priv_key(pub, loop_size) do
    steps(pub)
    |> Stream.drop(loop_size)
    |> Enum.take(1)
    |> hd()
  end

  def steps(subject), do: Stream.iterate(1, &step(&1, subject))
  def step(val, subject), do: rem(val * subject, @magic_number)

  def parse do
    input_string() |> String.trim() |> String.split("\n") |> Enum.map(&String.to_integer/1)
  end
end
