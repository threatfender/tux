defmodule TuxTest do
  use Tux.Case
  alias ExUnit.CaptureIO
  doctest Tux

  defmodule BlankProgram do
    use Tux.Dispatcher
  end

  # ------------------------------------------------------------

  defmodule Program do
    defmodule Echo do
      use Tux.Command

      @impl true
      def about(), do: "echo back the args"

      @impl true
      def main(_, args), do: {:ok, Enum.join(args, " ")}

      @impl true
      def help(), do: {:ok, "help message"}
    end

    defmodule Add do
      use Tux.Command

      def about(), do: "command with one preload"
      def main(env, args), do: {:ok, env.pre.adder.(args)}
      def help(), do: "help message"
    end

    defmodule Cat do
      use Tux.Command

      def about(), do: "command with two preloads"
      def main(env, args), do: {:ok, args |> env.pre.trimmer.() |> env.pre.joiner.()}
      def help(), do: "help message"
    end

    def adder(_env) do
      parse = fn str ->
        {num, ""} = Integer.parse(str)
        num
      end

      fn xs -> xs |> Enum.map(parse) |> Enum.sum() end
    end

    def trimmer(_env), do: fn xs -> Enum.map(xs, &String.trim/1) end
    def joiner(_env), do: fn xs -> Enum.join(xs) end

    use Tux.Dispatcher, colors: false

    cmd "echo", Echo
    cmd "add", Add, preloads: [:adder]
    cmd "cat", Cat, preloads: [:trimmer, joiner: {Program, :joiner, []}]
  end

  # ------------------------------------------------------------

  describe "commands" do
    scenario "empty dispatcher and no command given, shows blank",
      using: BlankProgram,
      invoke: "",
      expect: [exactly: ""]

    test "invocation with no command shows help" do
      help_msg = """
      Commands
        echo    echo back the args
        add     command with one preload
        cat     command with two preloads

      """

      assert CaptureIO.capture_io(fn ->
               Program.main([])
             end) == help_msg
    end

    scenario "simple command",
      using: Program,
      invoke: "echo 1 2 3",
      expect: [exactly: "1 2 3\n"]

    scenario "command with 1x preloads",
      using: Program,
      invoke: "add 1 2 3",
      expect: [exactly: "6\n"]

    scenario "command with 2x preloads",
      using: Program,
      invoke: "cat 1 2 3 --debug",
      expect: [exactly: "123\n"]

    scenario "undefined command",
      using: Program,
      invoke: "bad",
      expect: [approx: "Command not found"]
  end
end
