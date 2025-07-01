defmodule AdventOfCode.MixProject do
  use Mix.Project

  def project do
    [
      app: :advent_of_code,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :eex]
    ]
  end

  def cli do
    [preferred_envs: ["advent.test": :test]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.3"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:explorer, "~> 0.10.0"},
      {:httpoison, "~> 2.0"},
      {:typedstruct, "~> 0.5.3"},
      {:tz, "~> 0.26.5"}
    ]
  end
end
