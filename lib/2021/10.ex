import AOC

aoc 2021, 10 do
  def p1(input) do
    input
    |> String.split("\n")
    |> Stream.map(&parse/1)
    |> Stream.filter(&corrupted?/1)
    |> Stream.map(&hd/1)
    |> Stream.map(&elem(&1, 1))
    |> Stream.map(&syntax_score/1)
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> String.split("\n")
    |> Stream.map(&parse/1)
    |> Stream.reject(&corrupted?/1)
    |> Stream.map(fn [{:remaining, lst}] -> lst end)
    |> Stream.map(fn lst ->
      lst |> Enum.map(&completion_score/1) |> Enum.reduce(0, &(&2 * 5 + &1))
    end)
    |> Enum.sort()
    |> then(&Enum.at(&1, div(length(&1), 2)))
  end

  def corrupted?([{:delimiter, _} | _]), do: true
  def corrupted?(_), do: false

  def syntax_score(?)), do: 3
  def syntax_score(?]), do: 57
  def syntax_score(?}), do: 1197
  def syntax_score(?>), do: 25137

  def completion_score(?(), do: 1
  def completion_score(?[), do: 2
  def completion_score(?{), do: 3
  def completion_score(?<), do: 4

  def parse(str), do: parse(str, [])
  def parse(<<>>, []), do: []
  def parse(<<>>, stack), do: [{:remaining, stack}]
  def parse(<<c, r::binary>>, stack) when c in [?(, ?[, ?{, ?<], do: parse(r, [c | stack])
  def parse(<<?), r::binary>>, [?( | stack]), do: parse(r, stack)
  def parse(<<?], r::binary>>, [?[ | stack]), do: parse(r, stack)
  def parse(<<?}, r::binary>>, [?{ | stack]), do: parse(r, stack)
  def parse(<<?>, r::binary>>, [?< | stack]), do: parse(r, stack)
  def parse(<<c, r::binary>>, [_ | stack]), do: [{:delimiter, c} | parse(r, stack)]
end
