defmodule Tux.AlertTest do
  use ExUnit.Case
  doctest Tux.Alert

  alias Tux.Alert
  import ExUnit.CaptureIO, only: [capture_io: 2]

  describe "alert" do
    test "struct" do
      %Alert{}
    end

    test "with title and message" do
      alert = fn ->
        Alert.new()
        |> Alert.add(:tag, "ERR")
        |> Alert.add(:color, &Tux.Colors.red/1)
        |> Alert.add(:title, "Some title")
        |> Alert.add(:message, "Some message")
        |> IO.puts()
      end

      capture_io("ERR", alert)
      capture_io("Some title", alert)
      capture_io("Some message", alert)
    end

    test "with only title" do
      alert = fn ->
        Alert.new()
        |> Alert.add(:tag, "ERR")
        |> Alert.add(:color, &Tux.Colors.red/1)
        |> Alert.add(:title, "Some title")
        |> IO.puts()
      end

      capture_io("ERR", alert)
      capture_io("Some title", alert)
    end
  end
end
