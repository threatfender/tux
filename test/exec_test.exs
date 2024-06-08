defmodule Tux.ExecTest do
  use Tux.Case

  describe "exec" do
    test "use" do
      defmodule Ex do
        def device(), do: :stdio
        def cmds(), do: []
        require Tux.Exec
        Tux.Exec.__using__()
      end
    end
  end

  defmodule HelloError do
    use Tux.Error, message: "Hello Failure"
  end

  program "unbreakable", rescue: true do
    command "hello", do: raise(HelloError)
  end

  scenario "command execution rescued and shows alert when it fails",
    using: "unbreakable",
    invoke: "hello",
    expect: [approx: "ERR"]
end
