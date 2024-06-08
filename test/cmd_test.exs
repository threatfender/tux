defmodule Tux.CmdMacroTest do
  use Tux.Case

  describe "exec" do
    test "use" do
      defmodule Command do
        require Tux.Command
        Tux.Command.__using__()
      end
    end
  end

  test "tux command module cannot coincide with a dispatcher" do
    assert_raise(CompileError, ~r/.+`foo`.+/, fn ->
      defmodule Program do
        use Tux.Dispatcher
        cmd "foo", Program
      end
    end)
  end

  defmodule Cmd do
    use Tux.Command
    def main(_, _), do: {:ok, "it works"}
  end

  ###

  describe "register multiple names for a command at once" do
    program "foo_prog" do
      cmd ~w(foo f), Cmd
    end

    scenario "foo works (command full name)",
      using: "foo_prog",
      invoke: "foo",
      expect: [approx: "it works"]

    scenario "f works (command short name)",
      using: "foo_prog",
      invoke: "f",
      expect: [approx: "it works"]
  end
end
