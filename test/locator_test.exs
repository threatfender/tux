defmodule Tux.LocatorTest do
  use ExUnit.Case

  @cmds [
    {{:exact, "foo"}, FooModule, []},
    {{:exact, "bar"}, BarModule, []},
    {{:prefix, "ba"}, BaModule, []},
    {{:prefix, "za"}, ZarModule, []}
  ]

  test "exact match" do
    assert Tux.Locator.locate_cmd_module(@cmds, "foo") ==
             {:ok, {{:exact, "foo"}, FooModule, []}}
  end

  test "prefixed match" do
    assert Tux.Locator.locate_cmd_module(@cmds, "zar") ==
             {:ok, {{:prefix, "za"}, ZarModule, []}}
  end

  test "conflict match" do
    assert Tux.Locator.locate_cmd_module(@cmds, "bar") ==
             {:error, :cmd_conflict}
  end

  test "match not found" do
    assert Tux.Locator.locate_cmd_module(@cmds, "huh") ==
             {:error, :cmd_undefined}
  end
end
