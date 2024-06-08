defmodule QuickTest do
  use Tux.Case

  scenario "test ping cmd",
    using: Quick,
    invoke: "ping double",
    expect: [exactly: "pong\n"]

  describe "test greet commands" do
    scenario "hello cmd",
      using: Quick,
      invoke: "greet hello",
      expect: [exactly: "Hello there!\n"]

    scenario "bye cmd",
      using: Quick,
      invoke: "greet bye",
      expect: [exactly: "So long!\n"]
  end
end
