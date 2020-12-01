defmodule Aoc.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc,
      version: "0.1.0",
      elixir: "~> 1.7",
      deps: []
    ]
  end

  def application do
    [
      extra_applications: [:inets]
    ]
  end
end
