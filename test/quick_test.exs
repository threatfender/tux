defmodule Tux.QuickTest do
  use Tux.Case
  doctest Tux.Quick

  program "hier" do
    dispatcher "do" do
      command "ping", do: {:ok, "pong"}
      command "pong", do: {:ok, "ping"}

      dispatcher "as" do
        command "one", do: {:ok, "one"}
        command "two", do: {:ok, "two"}
      end
    end
  end

  scenario "`do ping` command",
    using: "hier",
    invoke: "do ping",
    expect: [exactly: "pong\n"]

  scenario "`do pong` command",
    using: "hier",
    invoke: "do pong",
    expect: [exactly: "ping\n"]

  scenario "`do as one` command",
    using: "hier",
    invoke: "do as one",
    expect: [exactly: "one\n"]

  scenario "`do as two` command",
    using: "hier",
    invoke: "do as two",
    expect: [exactly: "two\n"]
end
