defmodule Mix.Tasks.Aoc.Start do
  use Mix.Task
  @shortdoc "Create the appropriate file and fetch the input for a given day"

  def run(args) do
    {session, year, day} = parse_args(args)

    # Fetch input
    unless File.exists?(input_path(year, day)) do
      File.write(input_path(year, day), get_input(session, year, day))
    end

    unless File.exists?(code_path(year, day)) do
      File.write(code_path(year, day), template(year, day))
    end
  end

  defp parse_args(args) do
    {kw, _, _} = OptionParser.parse(
      args,
      aliases: [s: :session, y: :year, d: :day],
      strict: [session: :string, year: :integer, day: :integer]
    )

    session = Application.get_env(:aoc, :session, nil)
    year = Date.utc_today().year
    day = Date.utc_today().day

    {kw[:session] || session, kw[:year] || year, kw[:day] || day}
  end

  defp get_input(session, year, day) do
    Application.ensure_started(:inets)
    Application.ensure_started(:ssl)
    resp = :httpc.request(:get, {url(year, day), [cookie(session)]}, [], [])
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} = resp
    body
  end

  defp template(year, day) do
    """
    import AOC

    aoc #{year}, #{day} do
      def p1 do
      end

      def p2 do
      end
    end
    """
  end

  defp url(year, day), do: to_charlist("https://adventofcode.com/#{year}/day/#{day}/input")
  defp cookie(session), do: {'Cookie', to_charlist("session=#{session}")}

  defp input_path(year, day), do: "input/#{year}_#{day}.txt" |> Path.expand()
  defp code_path(year, day), do: "lib/#{year}/#{day}.ex" |> Path.expand()
end
