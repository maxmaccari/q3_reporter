defmodule Q3Reporter.MixProject do
  use Mix.Project

  def project do
    [
      app: :q3_reporter,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  def escript do
    [main_module: Q3Reporter.Cli]
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
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:jason, "~> 1.1"}
    ]
  end
end
