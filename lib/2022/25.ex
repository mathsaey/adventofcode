import AOC

aoc 2022, 25 do
  def p1(input), do: input |> parse() |> Enum.sum() |> to_snafu()

  @snafu_conversion %{0 => {0, 0}, 1 => {0, 1}, 2 => {0, 2}, 3 => {1, -2}, 4 => {1, -1}}
  @snafu_strings %{-1 => "-", -2 => "="}
  def to_snafu(num) do
    num
    |> Integer.digits(5)
    |> Enum.reduce([], fn digit, prev ->
      {carry, digit} = @snafu_conversion[digit]
      [digit | propagate_carry(carry, prev)]
    end)
    |> Enum.reverse()
    |> Enum.map(&(@snafu_strings[&1] || Integer.to_string(&1)))
    |> Enum.join()
  end

  def propagate_carry(0, prev), do: prev

  def propagate_carry(1, [hd | tl]) do
    if(hd + 1 <= 2, do: [hd + 1 | tl], else: [-2 | propagate_carry(1, tl)])
  end

  @snafu_digits %{"=" => -2, "-" => -1, "0" => 0, "1" => 1, "2" => 2}
  def read_snafu(string) do
    string
    |> String.codepoints()
    |> Enum.map(&@snafu_digits[&1])
    |> Integer.undigits(5)
  end

  def parse(input), do: input |> String.split("\n") |> Enum.map(&read_snafu/1)
end
