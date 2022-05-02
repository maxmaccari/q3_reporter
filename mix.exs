defmodule Q3Reporter.MixProject do
  use Mix.Project

  def project do
    [
      app: :q3_reporter,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.json": :test,
        "coveralls.lcov": :test
      ]
    ]
  end

  def escript do
    [main_module: Q3ReporterCli.Cli]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Q3Reporter.Application, []},
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:jason, "~> 1.1"},
      {:excoveralls, "~> 0.14", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0", only: :test}
    ]
  end
end
