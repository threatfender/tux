defmodule Tux.InitTest do
  use ExUnit.Case

  describe "init" do
    test "use" do
      defmodule In do
        def newlines?, do: true
        def device, do: :stdio
        def cmds, do: []
        def exitwith(), do: :halt
        require Tux.Init
        Tux.Init.__using__()
      end
    end
  end
end
