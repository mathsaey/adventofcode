import AOC

aoc 2023, 20 do
  def p1(input) do
    mods = parse(input)

    mods
    |> press_button_msg_stream()
    |> Stream.take(1000)
    |> Stream.flat_map(&Function.identity/1)
    |> Enum.reduce([0, 0], fn
      {_, _, :low}, [low, high] -> [low + 1, high]
      {_, _, :high}, [low, high] -> [low, high + 1]
    end)
    |> Enum.product()
  end

  def p2(input) do
    mods = parse(input)
    upstreams = find_upstreams(mods)

    mods
    |> press_button_msg_stream()
    |> Stream.map(&Enum.filter(&1, fn {sender, _, signal} ->
      sender in upstreams and signal == :high
    end))
    |> Stream.with_index(1)
    |> Stream.filter(fn {lst, _} -> lst != [] end)
    |> Stream.map(fn {[{sender, _, _}], idx} -> {sender, idx} end)
    |> Enum.reduce_while(%{}, fn {sender, idx}, found_pulses ->
      if map_size(found_pulses) == 4 do
        {:halt, found_pulses}
      else
        {:cont, Map.put_new(found_pulses, sender, idx)}
      end
    end)
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.reduce(&Utils.lcd/2)
  end

  def find_upstreams(mods), do: "rx" |> find_upstream(mods) |> hd() |> find_upstream(mods)

  def find_upstream(m, mods) do
    mods |> Enum.filter(fn {_, {_, subs}} -> m in subs end) |> Enum.map(fn {name, _} -> name end)
  end

  def press_button_msg_stream(mods) do
    mods
    |> initial_states()
    |> run(mods)
    |> Stream.iterate(fn {states, _} -> run(states, mods) end)
    |> Stream.map(fn {_, sent} -> sent end)
  end

  def run(states, mods), do: run(Qex.new([{"button", "broadcaster", :low}]), [], states, mods)

  def run(queue, sent, states, mods) do
    if Enum.empty?(queue) do
      {states, sent}
    else
      {msg, queue} = Qex.pop!(queue)
      {states, to_send} = process(msg, states, mods)
      queue = Qex.join(queue, Qex.new(to_send))
      run(queue, [msg | sent], states, mods)
    end
  end

  def process({sender, destination, signal}, states, mods) do
    {type, downstream} = Map.get(mods, destination, {:cast, []})
    case recv(type, sender, signal, states[destination]) do
      {:send, signal, state} ->
        {Map.put(states, destination, state), downstream |> Enum.map(&{destination, &1, signal})}
      {:nosend, state} ->
        {Map.put(states, destination, state), []}
    end
  end

  def recv(:cast, _, signal, state), do: {:send, signal, state}
  def recv(:flip, _, :high, on?), do: {:nosend, on?}
  def recv(:flip, _, :low, true), do: {:send, :low, false}
  def recv(:flip, _, :low, false), do: {:send, :high, true}

  def recv(:conj, sender, signal, state) do
    state = Map.put(state, sender, signal)
    {:send, if(state |> Map.values() |> Enum.all?(& &1 == :high), do: :low, else: :high), state}
  end

  def initial_states(mods) do
    conjs = mods |> Enum.filter(fn {_, {t, _}} -> t == :conj end) |> Enum.map(&elem(&1, 0))
    upstreams = conjs |> Enum.map(&{&1, []}) |> Map.new()

    upstreams =
      Enum.reduce(mods, upstreams, fn {name, {_, subs}}, upstreams ->
        subs |> Enum.filter(& &1 in conjs) |> Enum.reduce(upstreams, fn sub, upstreams ->
          Map.update!(upstreams, sub, &[name | &1])
        end)
      end)

    mods
    |> Enum.map(fn
      {name, {:flip, _}} -> {name, false}
      {name, {:cast, _}} -> {name, nil}
      {name, {:conj, _}} -> {name, upstreams[name] |> Enum.map(&{&1, :low}) |> Map.new()}
    end)
    |> Map.new()
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      [name, subs] = String.split(line, " -> ")
      {name, type} = parse_name(name)
      {name, {type, subs |> String.split(",") |> Enum.map(&String.trim/1)}}
    end)
    |> Map.new()
  end

  def parse_name(<<"%", name::binary>>), do: {name, :flip}
  def parse_name(<<"&", name::binary>>), do: {name, :conj}
  def parse_name("broadcaster"), do: {"broadcaster", :cast}
end
