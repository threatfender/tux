defmodule Recon.MixProject do
  use Mix.Project

  def project do
    [
      app: :recon,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def escript do
    [app: nil, main_module: Recon, path: "bin/recon"]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tux, path: "../.."},
      {:jason, "~> 1.4"}
    ]
  end
end
