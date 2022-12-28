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

    The grids should be represented as maps.
    """

    # TODO: neighbours, two and three dimensional. Option to include diagonals or not.
  end
end
