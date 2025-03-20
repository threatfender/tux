defmodule TuxNew.MixProject do
  use Mix.Project

  def project do
    [
      app: :tux_new,
      version: "0.4.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: [
        licenses: ["Apache-2.0"],
        files: ~w(lib priv mix.exs README.md),
        source_url: "https://github.com/threatfender/tux",
        source_ref: "master",
        links: %{
          "Homepage" => "https://tuxpkg.dev/",
          "GitHub" => "https://github.com/threatfender/tux"
        }
      ],
      description: """
      Command line project generator with tux dependency.

      Provides a `mix tux.new` task to bootstrap a new command line
      Elixir project with tux dependency and a default skeleton.
      """
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: []]
  end

  def docs do
    [main: "readme", extras: ["README.md"]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev}]
  end
end
