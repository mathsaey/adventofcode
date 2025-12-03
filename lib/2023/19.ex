import AOC

aoc 2023, 19 do
  def p1(input) do
    {rules, parts} = parse(input)
    tree = to_tree(rules, "in")

    parts
    |> Enum.filter(&(eval(&1, tree)))
    |> Enum.flat_map(&Map.values/1)
    |> Enum.sum()
  end

  def p2(input) do
    {rules, _} = parse(input)
    tree = to_tree(rules, "in")

    %{x: 1..4000, m: 1..4000, a: 1..4000, s: 1..4000}
    |> symbolic_eval(tree)
    |> Enum.reject(& &1 == false)
    |> Enum.map(fn map -> map |> Map.values() |> Enum.map(&Range.size/1) |> Enum.product() end)
    |> Enum.sum()
  end

  def symbolic_eval(ranges, [true]), do: [ranges]
  def symbolic_eval(_, [false]), do: [false]

  def symbolic_eval(ranges, [{lhs, :<, rhs, thn} | tl]) do
    low..high//_ = ranges[lhs]
    cond do
      rhs < low -> symbolic_eval(ranges, tl)
      rhs > high -> symbolic_eval(ranges, thn)
      true -> Enum.concat(
        symbolic_eval(Map.put(ranges, lhs, low..rhs - 1), thn),
        symbolic_eval(Map.put(ranges, lhs, rhs..high), tl)
      )
    end
  end

  def symbolic_eval(ranges, [{lhs, :>, rhs, thn} | tl]) do
    low..high//_ = ranges[lhs]
    cond do
      low > rhs -> symbolic_eval(ranges, thn)
      high < rhs -> symbolic_eval(ranges, thn)
      true ->
        Enum.concat(
          symbolic_eval(Map.put(ranges, lhs, rhs + 1..high), thn),
          symbolic_eval(Map.put(ranges, lhs, low..rhs), tl)
        )
    end
  end

  def eval(_, [bool]) when is_boolean(bool), do: bool

  def eval(part, [{lhs, :<, rhs, thn} | tl]) do
    if(part[lhs] < rhs, do: eval(part, thn), else: eval(part, tl))
  end

  def eval(part, [{lhs, :>, rhs, thn} | tl]) do
    if(part[lhs] > rhs, do: eval(part, thn), else: eval(part, tl))
  end

  def to_tree(_, "A"), do: [true]
  def to_tree(_, "R"), do: [false]

  def to_tree(rules, root) do
    Enum.flat_map(rules[root], fn
      {lhs, op, rhs, thn} -> [{lhs, op, rhs, to_tree(rules, thn)}]
      thn -> to_tree(rules, thn)
    end)
  end

  def parse(input) do
    [rules, parts] = String.split(input, "\n\n")
    {
      rules |> String.split("\n") |> Enum.map(&parse_workflow/1) |> Map.new(),
      parts |> String.split("\n") |> Enum.map(&parse_part/1)
    }
  end

  def parse_workflow(line) do
    [_, name, rules] = Regex.run(~r/(\w+)\{(.*)\}/, line)
    rules = rules |> String.split(",") |> Enum.map(&parse_rule/1)
    {name, rules}
  end

  def parse_rule(rule) do
    case Regex.run(~r/(\w)(<|>)(\d+):(\w+)/, rule) do
      nil ->
        rule
      [_, lhs, op, rhs, thn] ->
        {String.to_existing_atom(lhs), String.to_existing_atom(op), String.to_integer(rhs), thn}
    end
  end

  def parse_part(line) do
    ~r/\{x=(\d+),m=(\d+),a=(\d+),s=(\d+)\}/
    |> Regex.run(line)
    |> tl()
    |> Enum.map(&String.to_integer/1)
    |> then(fn [x, m, a, s] -> %{x: x, m: m, a: a, s: s} end)
  end
end
