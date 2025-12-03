import AOC

aoc 2023, 3 do
  def p1(input) do
    grid = parse(input)
    numbers = extract_numbers(grid)
    symbols = extract_symbols(grid)

    numbers
    |> Enum.filter(fn {pos, _} ->
      pos |> adjacent() |> Enum.any?(&Map.has_key?(symbols, &1))
    end)
    |> Enum.map(fn {_, num} -> num end)
    |> Enum.sum()
  end

  def p2(input) do
    grid = parse(input)
    numbers =
      grid
      |> extract_numbers()
      |> Enum.flat_map(fn num = {{start_x..stop_x//_, y}, _} ->
        for x <- start_x..stop_x, do: {{x, y}, num}
      end)
      |> Map.new()

    grid
    |> extract_symbols()
    |> Enum.filter(fn {_, v} -> v == "*" end)
    |> Enum.map(fn {k, _} -> k end)
    |> Enum.map(fn pos ->
      pos
      |> adjacent()
      |> Enum.map(&numbers[&1])
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq_by(fn {orig_pos, _} -> orig_pos end)
      |> Enum.map(fn {_, val} -> val end)
    end)
    |> Enum.filter(&length(&1) == 2)
    |> Enum.map(&Enum.product/1)
    |> Enum.sum()
  end

  def adjacent({start_x..stop_x//_, y}) do
    lst = for x <- start_x - 1..stop_x + 1, y <- [y - 1, y + 1], do: {x, y}
    [{start_x - 1, y}, {stop_x + 1, y} | lst]
    |> Enum.filter(fn {x, y} -> x >= 0 and y >= 0 end)
  end

  def adjacent({x, y}) do
    for x <- x - 1..x + 1, y <- y - 1..y + 1, x >= 0 and y >= 0, do: {x, y}
  end

  def extract_numbers(grid) do
    {max_x, _} = grid |> Map.keys() |> Enum.max_by(fn {x, _} -> x end)
    {_, max_y} = grid |> Map.keys() |> Enum.max_by(fn {_, y} -> y end)
    digits = grid |> Enum.filter(fn {_, v} -> is_integer(v) end) |> Map.new()

    for y <- 0..max_y do
      for x <- 0..max_x + 1, reduce: {nil, nil, []} do
        # We see the first digit of a number
        {nil, nil, nums} when is_map_key(digits, {x, y}) ->
          {{x..x, y}, [digits[{x, y}]], nums}
        # We are building a number and see another digit
        {{first_x.._//_, y}, prev, nums} when is_map_key(digits, {x, y}) ->
          {{first_x..x, y}, [digits[{x, y}] | prev], nums}
        # We are not building a number and don't see anything
        tup = {nil, nil, _} -> tup
        # We are building a number and see no new digit
        {coords, digits, nums} ->
          number = digits |> Enum.reverse() |> Integer.undigits()
          {nil, nil, [{coords, number} | nums]}
      end
    end
    |> Enum.flat_map(fn {nil, nil, nums} -> nums end)
  end

  def extract_symbols(grid) do
    grid
    |> Enum.filter(fn {_, v} -> is_binary(v) end)
    |> Map.new()
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> Enum.with_index()
      |> Enum.map(fn
        {<<n>>, x} when n in ?0..?9 -> {{x, y}, n - ?0}
        {".", x} -> {{x, y}, :empty}
        {p, x} -> {{x, y}, p}
      end)
    end)
    |> Map.new()
  end
end
