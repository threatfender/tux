defmodule Tux.HelpTest do
  use ExUnit.Case
  alias Tux.Help
  import Tux.Colors
  doctest Tux.Help

  test "empty help" do
    help = Help.new()
    assert %Help{} = help
    assert to_string(help) == ""
  end

  ###

  describe "colored help" do
    def colored do
      """
      #{bold("ABOUT")}
        cmd - description

      #{bold("USAGE")}
        #{green("cmd [OPTS] [ARGS]")}

      #{bold("COMMANDS")}
        #{green("start")}    Start something
        #{green("stop")}     Stop something

      #{bold("OPTIONS")}
        #{green("--flag1 FLAG")}    this flag does something
        #{green("--flag2 FLAG")}    this flag does something else
      """
    end

    test "construction (colored)" do
      help =
        Help.new()
        |> Help.about("cmd", "description")
        |> Help.usage(["cmd [OPTS] [ARGS]"])
        |> Help.commands([
          {"start", "Start something"},
          {"stop", "Stop something"}
        ])
        |> Help.options([
          {"--flag1 FLAG", "this flag does something"},
          {"--flag2 FLAG", "this flag does something else"}
        ])

      assert to_string(help) == colored()
    end
  end

  ###

  describe "(un)colored help" do
    def uncolored do
      """
      ABOUT
        cmd - description

      USAGE
        cmd [OPTS] [ARGS]

      OPTIONS
        --flag1 FLAG    this flag does something
        --flag2 FLAG    this flag does something else
      """
    end

    test "construction (uncolored)" do
      help =
        Help.new(color: false)
        |> Help.about("cmd", "description")
        |> Help.usage(["cmd [OPTS] [ARGS]"])
        |> Help.options([
          {"--flag1 FLAG", "this flag does something"},
          {"--flag2 FLAG", "this flag does something else"}
        ])

      assert to_string(help) == uncolored()
    end
  end

  ###

  describe "help message generation" do
    def generated() do
      """
      #{bold("COMMANDS")}
        #{green("sub")}       Sub command
        #{green("add, a")}
      """
    end

    test "help construction" do
      defmodule Program do
        use Tux.Dispatcher
        cmd "sub", Program.Sub
        cmd "add", Program.Add
        # A shortcut for the "add" command
        cmd "a", Program.Add

        defmodule Add do
          def main(_), do: :ok
        end

        defmodule Sub do
          def about(), do: "Sub command"
          def main(_), do: :ok
        end
      end

      {:ok, help} = Program.help()
      assert to_string(help) == generated()
    end
  end

  describe "more help tests" do
    def expected() do
      """
      #{bold("MORE")}
        Some more text

        And even more
      """
      |> String.trim_trailing()
    end

    test "" do
      help =
        Help.new()
        |> Help.title("MORE")
        |> Help.text("  Some more text")
        |> Help.newline()
        |> Help.text("  And even more")

      assert to_string(help) == expected()
    end
  end

  describe "alignments for" do
    def aligned() do
      """
      OPTIONS
        --flag1 FLAG    This flag does something
        --flag2 FLAG    This flag does something else
      """
    end

    test "flag descriptions" do
      help =
        Help.new(color: false)
        |> Help.options([
          {"--flag1 FLAG", "This flag does something"},
          {"--flag2 FLAG", "This flag does something else"}
        ])

      assert to_string(help) == aligned()
    end
  end
end
