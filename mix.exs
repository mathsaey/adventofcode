defmodule Aoc.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc,
      version: "0.1.0",
      elixir: "~> 1.7",
      deps: deps()
    ]
  end

  defp deps do
    [
      # Automatically reload code on change
      {:remix, "~> 0.0.1", only: :dev},
    ]
  end
end
