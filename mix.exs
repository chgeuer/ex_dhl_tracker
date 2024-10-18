defmodule ExDhlTracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_dhl_tracker,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.6"},
      {:kino, "~> 0.14.1"}    ]
  end
end
