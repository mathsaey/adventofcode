import AOC

aoc 2022, 5 do
  def p1(input), do: solve(input, &move_p1/2)
  def p2(input), do: solve(input, &move_p2/2)

  def solve(input, move_fun) do
    {stacks, steps} = parse(input)
    stacks = Enum.reduce(steps, stacks, fn step, stacks -> move_fun.(stacks, step) end)
    stacks |> Enum.map(fn {_, [t | _]} -> t end) |> Enum.join()
  end

  def move_p1(stacks, {0, _, _}), do: stacks

  def move_p1(stacks, {n, from, to}) do
    {el, stacks} = Map.get_and_update!(stacks, from, fn [el | stack] -> {el, stack} end)
    stacks |> Map.update!(to, &[el | &1]) |> move_p1({n - 1, from, to})
  end

  def move_p2(stacks, {n, from, to}) do
    {el, stacks} = Map.get_and_update!(stacks, from, &Enum.split(&1, n))
    stacks |> Map.update!(to, &(el ++ &1))
  end

  def parse(input) do
    [config, steps] = String.split(input, "\n\n")
    {parse_config(config), parse_steps(steps)}
  end

  def parse_config(config) do
    config
    |> String.split("\n")
    |> Enum.drop(-1)
    |> Enum.map(&parse_config_line/1)
    |> Enum.reverse()
    |> Enum.reduce(&Map.merge(&1, &2, fn _, [new], stack -> [new | stack] end))
  end

  def parse_config_line(line) do
    line
    |> String.codepoints()
    |> Enum.chunk_every(4)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&String.replace(&1, ~w([ ]), ""))
    |> Enum.map(&String.trim/1)
    |> Enum.with_index(1)
    |> Enum.reject(fn {el, _} -> el == "" end)
    |> Map.new(fn {el, idx} -> {idx, [el]} end)
  end

  def parse_steps(steps), do: steps |> String.split("\n") |> Enum.map(&parse_step/1)

  def parse_step(step) do
    ~r/move (\d+) from (\d+) to (\d+)/
    |> Regex.run(step)
    |> tl()
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end
