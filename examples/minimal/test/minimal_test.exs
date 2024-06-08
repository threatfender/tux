defmodule MinimalTest do
  use Tux.Case

  scenario "ping command",
    using: Minimal,
    invoke: "ping",
    expect: [exactly: "pong\n"]

  scenario "hello command",
    using: Minimal,
    invoke: "hello",
    expect: [approx: "Hello there"]
end
