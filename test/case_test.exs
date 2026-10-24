defmodule Tux.CaseTest do
  require Tux.Case
  Tux.Case.__using__()

  describe "case macros work & keep their formatting" do
    program "geometry" do
      command "shape", do: {:ok, "square"}

      dispatcher "more" do
        command "shapes", do: {:ok, "square rectangle"}
      end
    end

    test "execute macro with approx expect" do
      execute "geometry",
        invoke: "shape",
        expect: [approx: "square"]
    end

    test "execute macro with exact expect" do
      execute "geometry",
        invoke: "more shapes",
        expect: [exactly: "square rectangle\n"]
    end

    test "execute macro with exact expect w/ fn" do
      execute "geometry",
        invoke: "more shapes",
        expect: fn output -> assert "square rectangle\n" == output end
    end
  end
end
