defmodule Tux.CaseTest do
  require Tux.Case
  Tux.Case.__using__()

  describe "macros work & keep their formatting" do
    program "geometry" do
      command "shape", do: {:ok, "square"}

      dispatcher "more" do
        command "shapes", do: {:ok, "square rectangle"}
      end
    end

    scenario "geometry shape",
      using: "geometry",
      invoke: "shape",
      expect: [approx: "square"]

    test "geometry more shapes" do
      execute "geometry",
        invoke: "more shapes",
        expect: [exactly: "square rectangle\n"]
    end
  end
end
