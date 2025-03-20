defmodule <%= @main_module %>Test do
  use Tux.Case

  describe "main" do
    scenario "main",
      using: <%= @main_module %>,
      invoke: "",
      expect: [approx: "My program"]
  end

  describe "ping command" do
    scenario "ping",
      using: <%= @main_module %>,
      invoke: "ping",
      expect: [exactly: "pong\n"]

    scenario "ping -h",
      using: <%= @main_module %>,
      invoke: "ping -h",
      expect: [approx: "Show pong"]
  end

  describe "hello command" do
    scenario "hello",
      using: <%= @main_module %>,
      invoke: "hello",
      expect: [approx: "Hello,"]

    scenario "hello -h",
      using: <%= @main_module %>,
      invoke: "hello -h",
      expect: [approx: "Greet current user"]
  end
end
