import AOC

aoc 2019, 2 do

  def pre do
    input_string()
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> :array.from_list()
    |> :array.fix()
  end

  def p1 do
    pre()
    |> replace(12, 2)
    |> execute()
    |> first()
  end

  def p2 do
    arr = pre()
    input_combinations()
    |> Task.async_stream(fn {n, v} -> try(n, v, arr) end)
    |> Stream.map(&elem(&1, 1))
    |> Stream.filter(&(&1))
    |> Enum.to_list()
    |> hd()
  end

  defp input_combinations do
    Enum.flat_map(0..99, &(Enum.map(0..99, fn e -> {&1, e} end)))
  end

  defp try(noun, verb, arr) do
    output = arr |> replace(noun, verb) |> execute() |> first()
    case output do
      19690720 -> (100 * noun) + verb
      _ -> false
    end
  end

  defp first(arr), do: :array.get(0, arr)

  defp replace(arr, noun, verb) do
    arr = :array.set(1, noun, arr)
    arr = :array.set(2, verb, arr)
    arr
  end

  defp execute(arr, idx \\ 0) do
    case :array.get(idx, arr) do
      1 -> op(arr, idx, &Kernel.+/2) |> execute(idx + 4)
      2 -> op(arr, idx, &Kernel.*/2) |> execute(idx + 4)
      99 -> arr
    end
  end

  defp op(arr, idx, op) do
    left = :array.get(:array.get(idx + 1, arr), arr)
    right = :array.get(:array.get(idx + 2, arr), arr)
    res_idx = :array.get(idx + 3, arr)
    :array.set(res_idx, op.(left, right), arr)
  end
end
