import AOC

aoc 2022, 11 do
  import Kernel, except: [round: 1]
  def p1(input), do: solve(input, 20, &div(&1, 3))

  def p2(input) do
    lcd = input |> parse() |> lcd()
    solve(input, 10000, &rem(&1, lcd))
  end

  def solve(input, turns, fun) do
    input
    |> parse()
    |> Stream.iterate(&round(&1, fun))
    |> Stream.map(&Enum.map(&1, fn {_, %{inspected: c}} -> c end))
    |> Stream.drop(turns)
    |> Enum.take(1)
    |> hd()
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  def round(monkeys, fun), do: monkeys |> Map.keys() |> Enum.reduce(monkeys, &turn(&1, &2, fun))

  def turn(index, monkeys, fun) do
    %{operation: o, div_test: d, when_true: t, when_false: f, items: q} = monkeys[index]

    case Qex.pop(q) do
      {{:value, item}, q} ->
        level = item |> o.() |> fun.()
        target = if(divisible?(level, d), do: t, else: f)

        monkeys =
          monkeys
          |> put_in([index, :items], q)
          |> update_in([index, :inspected], &(&1 + 1))
          |> update_in([target, :items], &Qex.push(&1, level))

        turn(index, monkeys, fun)
      {:empty, _} ->
        monkeys
    end
  end

  def divisible?(dividend, divisor), do: rem(dividend, divisor) == 0

  def lcd(map), do: map |> Enum.map(fn {_, v} -> v.div_test end) |> Enum.reduce(&lcd/2)
  def lcd(a, b), do: div(a * b, Integer.gcd(a, b))

  def parse(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(&parse_monkey/1)
    |> Map.new()
  end

  def parse_monkey(input) do
    ~r"""
    Monkey (?'index'\d+):
      Starting items: (?'items'.+)
      Operation: new = old (?'operation'.+)
      Test: divisible by (?'div_test'\d+)
        If true: throw to monkey (?'when_true'\d+)
        If false: throw to monkey (?'when_false'\d+)\
    """
    |> Regex.named_captures(input)
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
    |> Map.update!(:index, &String.to_integer/1)
    |> Map.update!(:div_test, &String.to_integer/1)
    |> Map.update!(:when_true, &String.to_integer/1)
    |> Map.update!(:when_false, &String.to_integer/1)
    |> Map.update!(:operation, &parse_operation/1)
    |> Map.update!(:items, &parse_items/1)
    |> Map.put_new(:inspected, 0)
    |> Map.pop!(:index)
  end

  def parse_items(items) do
    items |> String.split(", ") |> Enum.map(&String.to_integer/1) |> Qex.new()
  end

  def parse_operation(<<"* old">>), do: fn prev -> prev * prev end
  def parse_operation(<<"+ old">>), do: fn prev -> prev + prev end
  def parse_operation(<<"+ ", n::binary>>), do: fn prev -> prev + String.to_integer(n) end
  def parse_operation(<<"* ", n::binary>>), do: fn prev -> prev * String.to_integer(n) end
end
