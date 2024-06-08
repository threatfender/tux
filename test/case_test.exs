defmodule Tux.CaseTest do
  require Tux.Case
  Tux.Case.__using__()

  program "program" do
    command "foo", do: {:ok, "bar"}
    command "bar", do: {:ok, "foo"}
  end

  test "exact scenario" do
    assert execute("program", invoke: "foo", expect: [exactly: "bar\n"])
  end

  test "approx scenario" do
    assert execute("program", invoke: "bar", expect: [approx: "f"])
  end
end
