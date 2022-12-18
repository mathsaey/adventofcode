import AOC

aoc 2022, 17 do
  @block_order [:-, :+, :j, :|, :o]
  @blocks %{
    -: for(x <- 0..3, do:  {x, 0}),
    +: [{1, 2}, {0, 1}, {1, 1}, {2, 1}, {1, 0}],
    j: [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}],
    |: for(y <- 0..3, do:  {0, y}),
    o: [{0, 0}, {1, 0}, {0, 1}, {1, 1}]
  }

  def p1(input), do: input |> run_n_blocks(2022) |> height()
  def p2(input), do: input |> find_height_with_cycles(1000000000000)

  def initial_state(input) do
    %{
      heights: 0 |> List.duplicate(7) |> List.to_tuple(),
      field: MapSet.new(),
      next_moves: input,
      moves: input,
      prev_states: %{},
      prev: %{},
    }
  end

  def run_n_blocks(input, n) do
    @block_order
    |> Stream.cycle()
    |> Stream.scan(initial_state(input), &block/2)
    |> Stream.drop(n - 1)
    |> Enum.take(1)
    |> hd()
  end

  def find_height_with_cycles(input, n) do
    {idx, state, prev_state} =
      @block_order
      |> Stream.cycle()
      |> Stream.with_index(1)
      |> Enum.reduce_while(initial_state(input), fn {block, idx}, state ->
        key = {block, state[:next_moves], offsets(state)}

        case state.prev_states[key] do
          nil ->
            state = put_in(state, [:prev_states, key], Map.put(state, :idx, idx))
            {:cont, block(block, state)}
          prev_state ->
            {:halt, {idx, state, prev_state}}
        end
      end)

    cycle_length = idx - prev_state[:idx]
    remaining_steps = n - idx

    cycle_times = div(remaining_steps, cycle_length)
    offset = rem(remaining_steps, cycle_length)

    height_increase = height(state) - height(prev_state)
    state = run_n_blocks(input, idx + offset)
    height(state) + height_increase * cycle_times
  end

  def block(block, state) when is_atom(block), do: block(spawn(block, state), state)

  def block(block, s = %{next_moves: "", moves: m}), do: block(block, %{s | next_moves: m})

  def block(block, s = %{next_moves: <<dir, next::binary>>}) do
    block
    |> move(dir, s)
    |> down(s)
    |> case do
      {:stuck, s} -> %{s | next_moves: next}
      {:continue, block} -> block(block, %{s | next_moves: next})
    end
  end

  def down(block, state = %{field: field, heights: heights}) do
    next = Enum.map(block, fn {x, y} -> {x, y - 1} end)
    if invalid?(next, state) do
      field = Enum.reduce(block, field, &MapSet.put(&2, &1))
      heights = Enum.reduce(block, heights, fn {x, y}, acc ->
        put_elem(acc, x, max(y + 1, elem(acc, x)))
      end)
      {:stuck, %{state | field: field, heights: heights}}
    else
      {:continue, next}
    end
  end

  def move(block, ?<, state), do: do_move(block, fn {x, y} -> {x - 1, y} end, state)
  def move(block, ?>, state), do: do_move(block, fn {x, y} -> {x + 1, y} end, state)

  def do_move(block, fun, state) do
    next = Enum.map(block, fun)
    if(invalid?(next, state), do: block, else: next)
  end

  def spawn(blk, state) do
    top = height(state)
    @blocks[blk] |> Enum.map(fn {x, y} -> {x + 2, top + 3 + y} end)
  end

  def invalid?(b, %{field: field}) do
    Enum.any?(b, fn t = {x, y} -> y < 0 || x not in 0..6 || t in field end)
  end

  def height(%{heights: h}), do: h |> Tuple.to_list() |> Enum.max()

  def offsets(s = %{heights: h}) do
    top = height(s)
    h |> Tuple.to_list() |> Enum.map(&(top - &1))
  end
end
