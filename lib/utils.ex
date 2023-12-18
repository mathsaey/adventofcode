defmodule Utils do
  @moduledoc """
  Useful functions that I kept on repeating.
  """

  @doc """
  Lowest common denominator.

  Does not work when a and b are zero.
  """
  def lcd(a, b), do: div(a * b, Integer.gcd(a, b))

  defmodule Grid do
    @moduledoc """
    Functions to work with grids.

    The grids are represented as maps.
    """

    # TODO: neighbours, two and three dimensional. Option to include diagonals or not.

    def bounds(grid) do
      coords = Map.keys(grid)
      {min_x, max_x} = coords |> Enum.map(fn {x, _} -> x end) |> Enum.min_max()
      {min_y, max_y} = coords |> Enum.map(fn {_, y} -> y end) |> Enum.min_max()
      {min_x..max_x, min_y..max_y}
    end

    def draw(grid, transform \\ &Function.identity/1, empty \\ ".") do
      {xs, ys} = bounds(grid)
      for y <- ys do
        for x <- xs do
          case grid[{x, y}] do
            nil -> IO.write(empty)
            e -> IO.write(transform.(e))
          end
        end
        IO.puts("")
      end
      grid
    end

    def input_to_map(input, parse_el \\ &Function.identity/1) do
      input
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {el, x} -> {{x, y}, parse_el.(el)} end)
      end)
      |> Map.new()
    end

    def input_to_map_with_bounds(input, parse_el \\ &Function.identity/1) do
      grid = input_to_map(input, parse_el)
      {grid, bounds(grid)}
    end
  end
end
