defmodule Tux.NestedDispatchersTest do
  use ExUnit.Case
  import ExUnit.CaptureIO, only: [capture_io: 1]

  defmodule Main.Foo.Bar.Zar.Start do
    use Tux.Command
    def main(_, _), do: {:ok, :started}
  end

  defmodule Main.Foo.Bar.Zar do
    use Tux.Dispatcher
    cmd "start", Main.Foo.Bar.Zar.Start
  end

  defmodule Main.Foo.Bar do
    use Tux.Dispatcher
    cmd "zar", Main.Foo.Bar.Zar
  end

  defmodule Main.Foo do
    use Tux.Dispatcher
    cmd "bar", Main.Foo.Bar
  end

  defmodule Main do
    use Tux.Dispatcher
    cmd "foo", Main.Foo
  end

  test "nested dispatches" do
    assert capture_io(fn ->
             Main.main(["foo", "bar", "zar", "start"])
           end) == "started\n"
  end
end
