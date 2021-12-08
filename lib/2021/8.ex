import AOC

# Matching edges and sizes
#      1  4  7  s
# 0 => 2  3  3 (6)
# 2 => 1  2  2 (5)
# 3 => 2  3  3 (5)
# 5 => 1  3  2 (3)
# 6 => 1  3  2 (6)
# 8 => 2  4  3 (7)
# 9 => 2  4  3 (6)

# Configuration indices:
#  1111
# 0    2
# 0    2
#  6666
# 5    3
# 5    3
#  4444

aoc 2021, 8 do
  @unique_segments [2, 4, 3, 7]

  def parse(stream) do
    stream
    |> Stream.map(fn str ->
      [l, r] = String.split(str, " | ")
      {parse_values(l), parse_values(r)}
    end)
  end

  def parse_values(str) do
    str
    |> String.split()
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(fn lst -> Enum.map(lst, &String.to_atom/1) end)
  end

  def p1 do
    input_stream()
    |> parse()
    |> Stream.flat_map(&elem(&1, 1))
    |> Stream.filter(&(length(&1) in @unique_segments))
    |> Enum.count()
  end

  def p2 do
    input_stream()
    |> parse()
    |> Stream.map(&decode/1)
    |> Enum.sum()
  end


  defmodule SearchSpace do
    @segments MapSet.new([:a, :b, :c, :d, :e, :f, :g])
    @postions MapSet.new(0..6)
    defstruct [:segments, :numbers]

    def create do
      segments = 1..7 |> Enum.map(fn _ -> @segments end) |> List.to_tuple()
      numbers = 0..9 |> Enum.map(fn _ -> nil end) |> List.to_tuple()
      %__MODULE__{segments: segments, numbers: numbers}
    end

    def get_num(m, n), do: elem(m.numbers, n)

    def to_map(%{numbers: tup}) do
      tup |> Tuple.to_list() |> Enum.with_index() |> Map.new()
    end

    # Update the search space after finding a new number
    def update(m, num, set, pos), do: m |> add_number_info(num, set) |> add_segment_info(set, pos)

    # Add a number to the known numbers
    defp add_number_info(m = %{numbers: n}, num, set), do: %{m | numbers: put_elem(n, num, set)}

    # Add new information to the configuration, we learn the elements in set are values for the
    # given list of positions. In these locations, we take the intersection of this set and the
    # data that is already present. In other locations, we remove the given values.
    defp add_segment_info(m = %{segments: segments}, set, filled_in) do
      intersect_ps = Enum.to_list(filled_in)
      diff_ps = MapSet.difference(@postions, MapSet.new(filled_in)) |> MapSet.to_list()

      segments =
        segments
        |> update_s(set, intersect_ps, &MapSet.intersection/2)
        |> update_s(set, diff_ps, &MapSet.difference/2)

      %{m | segments: segments}
    end

    # Update segments by applying f to the set at position p and the provided set.
    # When a list of positions is provided, update each of them.
    defp update_s(c, s, ps, f) when is_list(ps), do: Enum.reduce(ps, c, &update_s(&2, s, &1, f))
    defp update_s(c, s, p, f), do: put_elem(c, p, f.(elem(c, p), s))
  end

  def decode({l, r}) do
    codes = Enum.map(l, &MapSet.new/1)

    solved =
      codes
      |> Enum.reduce(SearchSpace.create(), &find_fixed_size_numbers/2)
      |> find_matching(0, codes, 0..5, 6, 2, 3, 3)
      |> find_matching(2, codes, [1, 2, 6, 5, 4], 5, 1, 2, 2)
      |> find_matching(3, codes, [1, 2, 6, 3, 4], 5, 2, 3, 3)
      |> find_matching(5, codes, [1, 0, 6, 3, 4], 5, 1, 3, 2)
      |> find_matching(6, codes, [1, 0, 6, 3, 4, 5], 6, 1, 3, 2)
      |> find_matching(8, codes, 0..6, 7, 2, 4, 3)
      |> find_matching(9, codes, [0, 1, 2, 3, 4, 6], 6, 2, 4, 3)
      |> SearchSpace.to_map()

    r
    |> Enum.map(&MapSet.new/1)
    |> Enum.map(&(solved[&1]))
    |> Integer.undigits()
  end

  def find_fixed_size_numbers(set, search) do
    case MapSet.size(set) do
      2 -> SearchSpace.update(search, 1, set, 2..3)
      3 -> SearchSpace.update(search, 7, set, 1..3)
      4 -> SearchSpace.update(search, 4, set, [0, 6, 2, 3])
      _ -> search
    end
  end

  def find_matching(search, num, sets, pos, size, m1, m4, m7) do
    match =
      sets
      |> Enum.map(fn set ->
        [set, MapSet.size(set) | Enum.map([1, 4, 7], &count_shared(set, search, &1))]
      end)
      |> Enum.find(fn [_, s, s1, s4, s7] -> size == s and s1 == m1 and s4 == m4 and s7 == m7 end)
      |> hd()
    SearchSpace.update(search, num, match, pos)
  end

  def count_shared(set, search, n) do
    search |> SearchSpace.get_num(n) |> MapSet.intersection(set) |> MapSet.size()
  end
end
