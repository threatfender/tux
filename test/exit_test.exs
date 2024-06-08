defmodule Tux.ExitTest do
  use ExUnit.Case
  doctest Tux.Exit

  test "__using__/1" do
    defmodule SomeModule do
      require Tux.Exit
      Tux.Exit.__using__()
    end

    SomeModule.exit(%Tux.Env{}, :ok)
  end
end
