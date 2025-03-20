defmodule Mix.Tasks.Tux.New do
  @moduledoc """
  Generate a command line Elixir project.

  ## Usage

  Generate a new project with a default tux skeleton:

      $ mix tux.new mycli

  Build, test & run the executable escript:

      $ cd mycli
      $ mix deps.get
      $ mix test

      $ mix escript.build
      $ ./mycli ping
      pong

  Third, install the escript locally:

      $ mix do escript.build + escript.install

  ## Update PATH

  To access your installed escript from anywhere on your machine do consider
  adding `~/.mix/escripts` directory to your `$PATH` environment variable.

  """

  use Mix.Task
  import TuxNew

  @shortdoc "Create a new tux-based CLI Elixir project"

  # mix new PATH [--app APP] [--module MODULE] [--sup] [--umbrella]
  def usage(), do: "USAGE: mix tux.new PATH [--sup]"

  def run([]), do: IO.puts(usage())

  def run(args) do
    with :ok <- validate_args(args),
         [path | _] <- args,
         :ok <- validate_path(path),
         :ok <- generate_app(args),
         :ok <- patch_app(args) do
      :ok
    else
      {:error, :invalid_args} ->
        IO.puts(usage())
        System.halt(1)

      {:error, msg} ->
        IO.puts("\nERROR:\n#{msg}")
        System.halt(1)
    end
  end
end
