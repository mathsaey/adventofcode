import AOC, only: :macros

aoc 2018, 5 do
  def get() do
    input_stream()
    |> Stream.take(1)
    |> Enum.to_list()
    |> hd()
    |> String.codepoints()
  end

  def p1() do
    get()
    |> collapse(true)
    |> length()
  end

  def p2() do
    # Start out from the collapsed list to cut down on execution time
    collapsed = collapse(get(), true)

    collapsed
    |> Enum.reduce(MapSet.new(), fn el, acc -> MapSet.put(acc, String.downcase(el)) end)
    |> Enum.map(
      fn element -> {
        element,
        collapsed
        |> Enum.reject(&does_match?(&1, element))
        |> collapse(true)
        |> length()
      }
      end)
      |> Enum.min_by(&elem(&1, 1))
      |> elem(1)
  end

  def collapse(lst, true) do
    {res, changed?} = collapse(lst)
    collapse(res, changed?)
  end

  def collapse(lst, false), do: lst

  def collapse([cur, next | rest]) do
    if does_match?(cur, next) and different_case?(cur, next) do
      {res, _} = collapse(rest)
      {res, true}
    else
      {res, changed?} = collapse([next | rest])
      {[cur | res], changed?}
    end
  end

  def collapse([cur | []]), do: {[cur], false}
  def collapse([]), do: {[], false}

  def is_upcase?(char), do: char == String.upcase(char)
  def does_match?(c1, c2), do: String.downcase(c1) == String.downcase(c2)
  def different_case?(c1, c2), do: is_upcase?(c1) != is_upcase?(c2)
end
