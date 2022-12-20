import AOC

aoc 2022, 19 do
  def p1(input) do
    input |> parse() |> simulate(24) |> Enum.map(fn {id, g} -> id * g end) |> Enum.sum()
  end

  def p2(input) do
    input |> parse() |> Enum.take(3) |> simulate(32) |> Enum.map(&elem(&1, 1)) |> Enum.product()
  end

  def simulate(blueprints, max_time) when is_list(blueprints) do
    blueprints
    |> Task.async_stream(&simulate(&1, max_time), timeout: :infinity)
    |> Enum.map(&elem(&1, 1))
  end

  def simulate({id, bp}, max_time) do
    initial_state()
    |> next_robots(bp, max_time)
    |> Enum.map(&(&1[:ores][:geo]))
    |> Enum.max()
    |> then(&{id, &1})
  end

  def initial_state do
    %{turn: 1, ores: %{ore: 1, cly: 0, obs: 0, geo: 0}, bots: %{ore: 1, cly: 0, obs: 0, geo: 0}}
  end

  def next_robots(state = %{turn: t}, _, max_time) when t >= max_time do
    Process.put(:max_geodes, max(Process.get(:max_geodes, 0), state[:ores][:geo]))
    [state]
  end

  # Calculate all possible next robots to create.
  # For each bot, we calculate the highest possible winning score (based on an optimistic scenario
  # of creating a geo bot every minute) and prune the branch if it is lower than the geodes
  # obtained by the best result seen so far.
  def next_robots(state, blueprint, max_time) do
    [:ore, :cly, :obs, :geo]
    |> Enum.reduce([], &maybe_add_bot(&2, &1, state, blueprint, max_time))
    |> Enum.reject(&(max_obtainable_score(&1, max_time) < Process.get(:max_geodes, 0)))
    |> Enum.flat_map(&next_robots(&1, blueprint, max_time))
  end

  def max_obtainable_score(%{turn: t, ores: %{geo: g}, bots: %{geo: gb}}, max_time) do
    remaining = max_time - t
    triangular = div(remaining * (remaining + 1), 2)
    g + remaining * gb + triangular
  end

  def maybe_add_bot(lst, bot, state, blueprint, max_time) do
    if bot_possible?(bot, state) and bot_useful?(bot, state, blueprint) do
      state = bot |> turns_required(state, blueprint) |> update_state(state, max_time)
      [add_bot(bot, state, blueprint) | lst]
    else
      lst
    end
  end

  # Verify we are mining the resources needed to build the bot
  def bot_possible?(bot, _) when bot in [:ore, :cly], do: true
  def bot_possible?(:obs, %{bots: %{cly: cb}}), do: cb != 0
  def bot_possible?(:geo, %{bots: %{obs: ob}}), do: ob != 0

  # Do not built bots that generate resources we don't need.
  # e.g. if we need 7 obsidian to build a geode bot, don't build more than 7 obsidian bots.
  def bot_useful?(:ore, %{bots: %{ore: ob}}, blueprint) do
    max_ore_cost = blueprint |> Enum.map(fn {_, %{ore: oc}} -> oc end) |> Enum.max()
    ob < max_ore_cost
  end

  def bot_useful?(:cly, %{bots: %{cly: cb}}, %{obs: %{cly: cc}}), do: cb < cc
  def bot_useful?(:obs, %{bots: %{obs: ob}}, %{geo: %{obs: oc}}), do: ob < oc
  def bot_useful?(:geo, _, _), do: true

  # Figure out how much turns we need to gather the resources to build this bot
  def turns_required(bot, state, blueprint) do
    blueprint[bot]
    |> Map.keys()
    |> Enum.map(&({&1, max(0, blueprint[bot][&1] - state[:ores][&1])}))
    |> Enum.map(fn {el, req} -> req / state[:bots][el] |> Float.ceil() |> trunc() end)
    |> Enum.max()
    |> Kernel.+(1)
  end

  def update_state(turns, state = %{turn: t}, max_time) when t + turns > max_time do
    update_state(max_time - t, state, max_time)
  end

  def update_state(turns, state = %{turn: t, ores: ores, bots: bots}, _) do
    ores =
      bots
      |> Map.new(fn {bot, amount} -> {bot, amount * turns} end)
      |> Map.merge(ores, fn _, g, o -> g + o end)

    %{state | turn: t + turns, ores: ores}
  end

  def add_bot(bot, state = %{bots: bots, ores: ores}, blueprint) do
    bots = Map.update!(bots, bot, &(&1 + 1))
    ores = Map.merge(ores, blueprint[bot], fn _, o, c -> o - c end)
    %{state | bots: bots, ores: ores}
  end

  ore = "Each ore robot costs (\\d+) ore."
  clay = "Each clay robot costs (\\d+) ore."
  obsidian = "Each obsidian robot costs (\\d+) ore and (\\d+) clay."
  geode = "Each geode robot costs (\\d+) ore and (\\d+) obsidian."
  @regex ~r/Blueprint (\d+): #{ore} #{clay} #{obsidian} #{geode}/

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      @regex
      |> Regex.run(line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)
      |> then(fn [id, ore, cly, obs_ore, obs_cly, geo_ore, geo_obs] ->
        {id, %{
          ore: %{ore: ore},
          cly: %{ore: cly},
          obs: %{ore: obs_ore, cly: obs_cly},
          geo: %{ore: geo_ore, obs: geo_obs}
        }}
      end)
    end)
  end
end
