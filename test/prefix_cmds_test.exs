defmodule Tux.PrefixedCommandsTest do
  use Tux.Case

  defmodule Program do
    use Tux.Dispatcher

    defmodule Greet do
      use Tux.Command

      def main(env, _) do
        case String.split(env.cmd, ".", parts: 2) do
          ["hello"] -> {:ok, "hello anonymous"}
          ["hello", who] -> {:ok, "hello #{who}"}
        end
      end
    end

    cmd ~p"hello", Greet
  end

  scenario "prefixed 1",
    using: Program,
    invoke: "hello",
    expect: [exactly: "hello anonymous\n"]

  scenario "prefixed 2",
    using: Program,
    invoke: "hello.world",
    expect: [exactly: "hello world\n"]

  test "prefixed commands are included in generated help" do
    {:ok, help} = Program.help()
    string = to_string(help)
    assert string =~ "hello[...]"
  end

  test "conflicting command names" do
    assert_raise CompileError, fn ->
      defmodule ConflictingCommands do
        use Tux.Dispatcher
        cmd "hello", Program.Greet
        cmd ~p"he", Program.Greet
      end
    end

    assert_raise CompileError, fn ->
      defmodule ConflictingCommands2 do
        use Tux.Dispatcher
        cmd "hello", Program.Greet
        cmd "hello", Program.Greet
      end
    end
  end
end
