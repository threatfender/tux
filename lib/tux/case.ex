defmodule Tux.Case do
  @moduledoc """
  Utility macros to generate test cases for dispatchers or main
  escript modules.

  ## Examples

  The following example uses the `scenario/2` macro to create the
  entire `ExUnit.Case` test cases in a single step:

      defmodule MyTests do
        use Tux.Case

        scenario "check for EXACT output",
          using: SomeDispatcher,
          invoke: "ping --flag --flag",
          expect: [exactly: "pong\\n"]

        scenario "check for APPROXIMATE command output",
          using: SomeDispatcher,
          invoke: "ping --flag --flag",
          expect: [approx: "pong"]

        scenario "check command output using CUSTOM FUN",
          using: SomeMainModule,
          invoke: "ping --flag --flag",
          expect: fn output ->
            assert String.contains?(output, "pong")
          end
      end

  This module also includes the `execute/2` macro, which does not setup a test case
  and only asserts on the command output. This is useful if you need control
  over how you create your test cases:

      defmodule MyTests do
        use Tux.Case

        test "some test using the lower level execute macro" do
          execute SomeDispatcher,
            invoke: "ping --with --some --flags"
            expect: [exactly: "pong\\n"]
        end
      end
  """

  @doc """
  Execute the main function of a given dispatcher module using the given command string
  and assert on the result or run a custom function.

  ## Examples

      defmodule MyTests do
        use Tux.Case

        test "check for exact pong" do
          execute MyProgram,
            invoke: "ping --with --some --flags"
            expect: [exactly: "pong\\n"]
        end


  Note that the `expect` part given to this macro takes can take multiple
  shapes:

      execute MyProgram,
        ...
        expect: [exactly: "pong\\n"]

      execute MyProgram,
        ...
        expect: [approx: "pong"]

      execute MyProgram,
        ...
        expect: fn output -> assert output =~ "ping" end

  """
  defmacro execute(program, invoke: cmd_str, expect: {:fn, _, _} = fun) do
    quote do
      output =
        ExUnit.CaptureIO.capture_io(fn ->
          args = OptionParser.split(unquote(cmd_str))
          program(unquote(program)).main(args)
        end)

      unquote(fun).(output)
    end
  end

  defmacro execute(program, invoke: cmd_str, expect: expect) do
    {operator, expected} =
      case expect do
        [approx: expected] -> {:=~, expected}
        [exactly: expected] -> {:==, expected}
      end

    quote do
      output =
        ExUnit.CaptureIO.capture_io(fn ->
          args = OptionParser.split(unquote(cmd_str))
          program(unquote(program)).main(args)
        end)

      assert apply(Kernel, unquote(operator), [output, unquote(expected)])
    end
  end

  @doc """
  This macros wraps the `execute/2` macro with ExUnit.Case test case.

  ## Examples

  Create a new test case and check for an *exact* command output:

      defmodule MyTest do
        use Tux.Case

        scenario "exact output",
          using: MyProgram,
          invoke: "command --flag --flag",
          expect: [exactly: "some output\\n"]
      end

  Create a new test case and check for an *approximate* command output:

      scenario "partial output",
        ...
        expect: [approx: "some output"]

  Alternatively, the `:expect` field can be an anonymous function which receives
  one argument (the command output) and performs its own asserts:

      scenario, "custom function",
        ...
        expect: fn output -> assert output =~ "something" end

  """
  defmacro scenario(title, using: program, invoke: command, expect: result) do
    quote do
      test unquote(title) do
        execute(unquote(program), invoke: unquote(command), expect: unquote(result))
      end
    end
  end

  @doc """
  This implements the functionality `use Tux.Case`.

  ## Options

    - The give options will be passed to `ExUnit.Case`.

  """
  defmacro __using__(opts \\ []) do
    quote do
      use ExUnit.Case, unquote(opts)
      import Tux.Quick
      import Tux.Case
    end
  end
end
