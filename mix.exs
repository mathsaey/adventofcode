defmodule Aoc.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc,
      version: "0.1.0",
      elixir: "~> 1.12",
      deps: deps()
    ]
  end

  defp deps do
    [
      {:advent_of_code_utils, "~> 1.0"}
    ]
  end
end
