defmodule Tux.DispatcherTest do
  use ExUnit.Case
  doctest Tux.Dispatcher

  alias Tux.Env
  alias Tux.Help

  test "dispatcher struct" do
    assert %Tux.Dispatcher{} = %Tux.Dispatcher{}
  end

  import ExUnit.CaptureLog

  describe "command" do
    test "use" do
      defmodule Cm do
        require Tux.Dispatcher
        Tux.Dispatcher.__using__()
      end
    end

    test "with missing module" do
      assert capture_log(fn ->
               defmodule BdMod do
                 use Tux.Dispatcher
                 cmd "add", BadModule
               end
             end) =~
               "BadModule is registered as a command module, " <>
                 "but hasn't been compiled, reason = nofile."
    end

    test "with missing module main" do
      assert capture_log(fn ->
               defmodule BdMain do
                 defmodule SubModuleNoMain do
                 end

                 use Tux.Dispatcher
                 cmd "sub", SubModuleNoMain
               end
             end) =~
               "Tux.DispatcherTest.BdMain.SubModuleNoMain is registered as a command module, " <>
                 "but hasn't implemented a `main` function."
    end
  end

  defmodule HelpOverridden do
    use Tux.Dispatcher

    # Override help
    def help(), do: Help.new() |> Help.section("some section", "some desc")
  end

  describe "help" do
    test "use" do
      defmodule He do
        def device(), do: :stdio
        def cmds(), do: []
        require Tux.Help
        Tux.Help.__using__(overridable: true, for: :dispatcher)
      end
    end

    test "override" do
      assert HelpOverridden.help() == Help.new() |> Help.section("some section", "some desc")
    end
  end
end
