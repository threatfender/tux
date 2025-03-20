defmodule TuxNewTest do
  use ExUnit.Case
  import ExUnit.CaptureIO, only: [capture_io: 1]
  alias Mix.Tasks.Tux.New

  test "mix tux.new (blank)" do
    out = capture_io(fn -> New.run([]) end)
    assert out =~ "USAGE"
  end

  test "mix tux.new (with bad args)" do
    out = capture_io(fn -> New.run(["bla", "bla"]) end)
    assert out =~ "USAGE: mix tux.new"
  end

  test "mix tux.new PATH" do
    generate(["pinger"])
    build_test_run("pinger")
    File.rm_rf!("pinger")
  end

  test "mix tux.new PATH --sup" do
    generate(["pinger_app", "--sup"])
    build_test_run("pinger_app")
    File.rm_rf!("pinger_app")
  end

  defp generate(args) do
    assert capture_io(fn -> New.run(args) end) =~ "Build & run your escript"
  end

  defp build_test_run(name) do
    IO.puts("* Build, test & run generated app: #{name}")

    # Fetch deps and build script
    {_, 0} = System.cmd("mix", ["deps.get"], cd: name)
    {_, 0} = System.cmd("mix", ["test", "--cover"], cd: name)
    {_, 0} = System.cmd("mix", ["escript.build"], cd: name)

    # Execute escript and check output
    cmd = Path.expand("../#{name}/#{name}", __DIR__)
    {out, 0} = System.cmd(cmd, ["ping"], cd: name)
    assert out == "pong\n"
  end
end
