defmodule Tux.EnvTest do
  use ExUnit.Case
  alias Tux.Env

  describe "env" do
    test "construction" do
      env =
        Env.new()
        |> Env.add(:raw, [])
        |> Env.add(:cmd, "cmd")
        |> Env.add(:mod, :main)
        |> Env.add(:fun, __MODULE__)
        |> Env.add(:pre, %{})
        |> Env.add(:arg, [])
        |> Env.add(:dev, :stdio)
        |> Env.add(:dsp, __MODULE__)
        |> Env.add(:new, true)
        |> Env.add(:ext, :halt)

      assert env.cmd == "cmd"
    end
  end
end
