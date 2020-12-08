import AOC

aoc 2020, 8 do
  def p1, do: parse() |> run_until_revisit() |> elem(1)
  def p2, do: parse() |> find_flip()

  def parse do
    input_stream()
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [l, r] -> {String.to_existing_atom(l), String.to_integer(r)} end)
    |> :array.from_list()
  end

  def find_flip(original_prg, ctr \\ 0) do
    {changed_prg, ctr} = flip(original_prg, ctr)
    case run_until_revisit(changed_prg) do
      {:done, acc} -> acc
      _ -> find_flip(original_prg, ctr + 1)
    end
  end

  def flip(prg, idx) do
    ins = :array.get(idx, prg)
    case ins do
      {:nop, arg} -> {:array.set(idx, {:jmp, arg}, prg), idx}
      {:jmp, arg} -> {:array.set(idx, {:nop, arg}, prg), idx}
      _ -> flip(prg, idx + 1)
    end
  end

  def run_until_revisit(prg, ic \\ 0, acc \\ 0, visited \\ []) do
    {ic, acc} = step(prg, ic, acc)

    cond do
      ic == :done -> {:done, acc}
      ic in visited -> {:loop, acc}
      true -> run_until_revisit(prg, ic, acc, [ic | visited])
    end
  end

  def step(prg, ic, acc) do
    case :array.get(ic, prg) do
      {ins, arg} -> exec(ins, arg, ic, acc)
      :undefined -> {:done, acc}
    end
  end

  def exec(:nop, _, ic, acc), do: {ic + 1, acc}
  def exec(:jmp, n, ic, acc), do: {ic + n, acc}
  def exec(:acc, n, ic, acc), do: {ic + 1, acc + n}
end
