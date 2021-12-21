import AOC

aoc 2019, 4 do
  def range do
    [from, to] = input_string() |> String.split("-") |> Enum.map(&String.to_integer/1)
    from..to
  end

  def post(stream) do
    stream
    |> Stream.filter(&(&1))
    |> Enum.to_list()
    |> length()
  end

  def p1 do
    range()
    |> Stream.map(&(adjacent_digits(&1) and digits_increase(&1)))
    |> post()
  end

  def p2 do
    range()
    |> Stream.map(&(adjacent_double_digits(&1) and digits_increase(&1)))
    |> post()
  end

  def digits_increase(n) do
    n
    |> Integer.digits()
    |> Enum.reduce_while(0, fn
      el, prev when el >= prev -> {:cont, el}
      _, _ -> {:halt, false}
    end)
    |> Kernel.!=(false)
  end

  def adjacent_digits(n) do
    n
    |> Integer.digits()
    |> Enum.reduce_while(-1, fn
      el, el -> {:halt, true}
      el, _ -> {:cont, el}
    end)
    |> Kernel.==(true)
  end

  def adjacent_double_digits(n) do
    n
    |> Integer.digits()
    |> Kernel.++([-1])
    |> Enum.reduce_while({-1, 0}, fn
      el, {prev, 1} when el != prev -> {:halt, true}
      el, {el, ctr} -> {:cont, {el, ctr + 1}}
      el, {_, _} -> {:cont, {el, 0}}
    end)
    |> Kernel.==(true)
  end
end
