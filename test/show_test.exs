defmodule Tux.ShowTest do
  use Tux.Case
  doctest Tux.Show

  test "__using__" do
    defmodule MyModule do
      require Tux.Show
      Tux.Show.__using__()
    end
  end

  describe "command returns various results" do
    program "prog" do
      command "ok1", do: :ok
      command "ok2", do: {:ok, ""}
      command "ok3", do: {:ok, "result"}
      command "er1", do: :error
      command "er2", do: {:error, %Tux.Error{message: "Some Failure"}}
      command "er3", do: {:error, :atom}
      command "bd1", do: "Bad return"
    end

    # OK
    scenario "command returns just :ok",
      using: "prog",
      invoke: "ok1",
      expect: [exactly: ""]

    scenario "command returns {:ok, empty string}",
      using: "prog",
      invoke: "ok2",
      expect: [exactly: ""]

    scenario "command returns {:ok, some string}",
      using: "prog",
      invoke: "ok3",
      expect: [exactly: "result\n"]

    # ERRORS
    scenario "command returns just :error",
      using: "prog",
      invoke: "er1",
      expect: [approx: "Command Returned Just Error"]

    scenario "command returns {:error, some explainable}",
      using: "prog",
      invoke: "er2",
      expect: [approx: "ERR"]

    scenario "command returns {:error, some atom}",
      using: "prog",
      invoke: "er3",
      expect: [approx: ":atom"]

    ## BAD RETURNS
    test "bad return" do
      assert_raise RuntimeError, ~r/.+Non-standard command result+/, fn ->
        program("prog").main(["bd1"])
      end
    end
  end

  describe "program does not print new lines for results" do
    program "no_new_line", newlines: false do
      command "hola", do: {:ok, "hola"}
    end

    scenario "program does not print newlines",
      using: "no_new_line",
      invoke: "hola",
      expect: [exactly: "hola"]
  end

  describe "overriding show functions for commands and dispatchers" do
    defmodule ShowOverrider do
      use Tux.Dispatcher

      defmodule Echo do
        use Tux.Command
        def main(_env, args), do: {:ok, Enum.join(args, " ")}
        def show(_env, {:ok, result}), do: IO.puts("- #{result}")
      end

      @impl true
      def show(_, _), do: IO.puts("This overrides dispatcher's show function")

      cmd "echo", Echo
    end

    scenario "the show function of command module is overriden",
      using: ShowOverrider,
      invoke: "echo 1 2 3",
      expect: [exactly: "- 1 2 3\n"]

    scenario "the show function of dispatcher module is overriden",
      using: ShowOverrider,
      invoke: "",
      expect: [exactly: "This overrides dispatcher's show function\n"]
  end
end
