import AOC

aoc 2020, 16 do
  def p1 do
    {constraints, _, nearby} = parse(input_string())
    nearby |> Enum.flat_map(fn t -> Enum.reject(t, &valid?(&1, constraints)) end) |> Enum.sum()
  end

  def p2 do
    {constraints, mine, nearby} = parse(input_string())

    nearby
    |> Enum.filter(fn t -> Enum.all?(t, &valid?(&1, constraints)) end)
    |> collums()
    |> Enum.map(&possibilities(&1, constraints))
    |> drop_certain()
    |> Enum.zip(mine)
    |> Enum.filter(&(&1 |> elem(0) |> String.starts_with?("departure")))
    |> Enum.map(&elem(&1, 1))
    |> Enum.reduce(&(&1 * &2))
  end

  def collums(nearby), do: nearby |> Enum.zip() |> Enum.map(&Tuple.to_list/1)

  def possibilities(col, constraints) do
    constraints
    |> Enum.filter(fn {_, {r1, r2}} -> Enum.all?(col, &(&1 in r1 or &1 in r2)) end)
    |> Enum.map(&elem(&1, 0))
  end

  def drop_certain(lst, acc \\ MapSet.new()) do
    {lst, acc} = Enum.map_reduce(lst, acc, fn
      [el], acc -> {el, MapSet.put(acc, el)}
      lst, acc when is_list(lst) -> {Enum.reject(lst, &(&1 in acc)), acc}
      el, acc -> {el, acc}
    end)

    if Enum.any?(lst, &is_list/1), do: drop_certain(lst, acc), else: lst
  end

  def ranges(constraints), do: constraints |> Map.values() |> Enum.flat_map(&Tuple.to_list/1)
  def valid?(field, constraints), do: Enum.any?(ranges(constraints), &(field in &1))

  # Parsing
  # -------

  def parse(string) do
    [constraints, mine, nearby] = string |> String.split("\n\n")
    {parse_constraints(constraints), parse_mine(mine), parse_nearby(nearby)}
  end

  def parse_constraints(str) do
    str
    |> String.split("\n")
    |> Enum.map(fn s ->
      [_, c, lf, lt, rf, rt] = Regex.run(~r/^(.+): (\d+)-(\d+) or (\d+)-(\d+)/, s)
      {c, {
        String.to_integer(lf)..String.to_integer(lt),
        String.to_integer(rf)..String.to_integer(rt)
      }}
    end)
    |> Map.new()
  end

  def parse_mine(<<"your ticket:\n", fields :: binary>>), do: parse_ticket(fields)

  def parse_nearby(<<"nearby tickets:\n", fields :: binary>>) do
    fields |> String.split("\n") |> Enum.map(&parse_ticket/1)
  end

  def parse_ticket(str), do: str |> String.split(",") |> Enum.map(&String.to_integer/1)
end
