defmodule Tux.EscriptTest do
  use ExUnit.Case

  defmodule Escript do
    @moduledoc """
    A module to handle operations on the `testo` escript
    """

    @app "testo"

    defp upgrade_syspath() do
      new_dir = Path.join([__DIR__, "apps", @app])
      new_path = "#{System.get_env("PATH")}:#{new_dir}"
      System.put_env("PATH", new_path)
    end

    @doc """
    Run a system command inside the `@app` directory
    """
    def build() do
      {out, 0} =
        System.cmd("mix", ["escript.build"], cd: Path.join(["test", "apps", @app]))

      true = out =~ "Generated escript"
      :ok
    end

    @doc """
    Run a command using the `@app` escript executable
    """
    def run(args) do
      :ok = upgrade_syspath()
      System.cmd(@app, args)
    end

    @doc """
    Remove build artifacts: dirs, escript executable.
    """
    def cleanup() do
      {:ok, _} = File.rm_rf(Path.join([__DIR__, "apps", @app, "_build"]))
      :ok = File.rm(Path.join([__DIR__, "apps", @app, @app]))
    end
  end

  setup_all do
    :ok = Escript.build()
    on_exit(fn -> Escript.cleanup() end)
  end

  describe "generate and test an escript" do
    test "existing cmd" do
      {"pong\n", 0} = Escript.run(["ping"])
    end

    test "invalid cmd" do
      {out, 1} = Escript.run(["bla"])
      assert out =~ "Command not found"
    end

    test "custom exit code cmd" do
      {out, 3} = Escript.run(["exit"])
      assert out =~ "Exit code should be 3"
    end

    test "nested preloads" do
      {out, 0} = Escript.run(["bump", "bump", "bump"])
      assert out == "3\n"
    end
  end
end
