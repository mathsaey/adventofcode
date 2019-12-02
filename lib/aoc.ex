defmodule AOC do
  defmacro aoc(year, day, do: body) do
    quote do
      defmodule unquote(module_name(year, day)) do
        @path"input/#{unquote(year)}_#{unquote(day)}.txt"

        def input_path, do: @path

        def input_stream do
          @path
          |> Path.expand()
          |> File.stream!()
          |> Stream.map(&String.trim/1)
        end

        unquote(body)
      end
    end
  end

  defp module_name(year, day) do
    mod_year = "Y#{year}" |> String.to_atom()
    mod_day = "D#{day}" |> String.to_atom()
    Module.concat(mod_year, mod_day)
  end

  # Helpers to make the iex experience a bit smoother
  def p1(), do: p1(Date.utc_today.day(), Date.utc_today().year)
  def p2(), do: p2(Date.utc_today.day(), Date.utc_today().year)
  def p1(day), do: p1(day, Date.utc_today().year)
  def p2(day), do: p2(day, Date.utc_today().year)
  def p1(day, year), do: module_name(year, day).p1()
  def p2(day, year), do: module_name(year, day).p2()
end
