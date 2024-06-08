defmodule Tux.ColorsTest do
  use ExUnit.Case

  test "colors" do
    colors = [
      :underline,
      :bold,
      :red,
      :yellow,
      :green,
      :blue,
      :gray,
      :faint,
      :orange
    ]

    msg = "hello"

    for name <- colors do
      out = apply(Tux.Colors, name, [msg])
      assert out =~ msg

      out = apply(Tux.Colors, name, [msg, false])
      assert out == msg
    end
  end
end
