defmodule Tux.MixProject do
  use Mix.Project

  @version "0.4.0"

  def project do
    [
      app: :tux,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),

      # Hex
      package: package(),
      description: "Create elegant commmand line interfaces with ease",

      # Docs
      name: "Tux",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "Homepage" => "https://tuxlib.dev/",
        "GitHub" => "https://github.com/threatfender/tux"
      },
      files: ~w(lib mix.exs .formatter.exs CHANGELOG.md README.md LICENSE)
    ]
  end

  defp docs do
    [
      main: "Tux",
      logo: "assets/logo.png",
      source_url: "https://github.com/threatfender/tux",
      source_ref: "master",
      extras: ["CHANGELOG.md"],
      # extra_section: "GUIDES",
      groups_for_modules: [
        "Command Creation": [
          Tux.Dispatcher,
          Tux.Command
        ],
        "Command IO": [
          Tux.Case,
          Tux.Colors,
          Tux.Config,
          Tux.Env,
          Tux.Error,
          Tux.Help,
          Tux.Prompt,
          Tux.Result
        ],
        Internals: [
          Tux.Alert,
          Tux.Alertable,
          Tux.Errors,
          Tux.Exec,
          Tux.Exit,
          Tux.Init,
          Tux.Locator,
          Tux.Quick,
          Tux.Show
        ]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: :dev, runtime: false},
      {:sobelow, "~> 0.13", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      "src.analyze": &analyze_src/1,

      # Hex package
      "pkg.build": &build_pkg/1,
      "pkg.analyze": ["pkg.build", &analyze_pkg/1]
    ]
  end

  ## Package source code

  defp analyze_src(_) do
    Mix.Task.run("sobelow")
    Mix.Task.run("dialyzer")
    Mix.Task.run("credo", ["--all"])
  end

  ## Package archive

  defp build_pkg(_) do
    Mix.Task.run("hex.build")
  end

  defp analyze_pkg(_) do
    archive = "tux-#{@version}.tar"
    Mix.Shell.IO.info("\nAnalyzing #{archive}")

    tarsize = File.stat!(archive).size
    Mix.Shell.IO.info("- Size: #{tarsize / 1024} kb")
  end
end
