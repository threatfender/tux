defmodule Tux.Command do
  @moduledoc """
  A command module provides the implementation for a given command,
  and it can be registered on a given dispatcher using the
  `Tux.Dispatcher.cmd/2` macro.

  At a minimum, a command module needs to implement only the `c:main/2` callback.
  The full list of callbacks is as follows:

    * `c:main/2` (**required**)
      – implements the command logic.
    * `c:about/0` (**optional**)
      – returns the command's short description.
    * `c:help/0` (**optional**)
      – returns command's help message – see `Tux.Help`.
    * `c:show/2` (**optional**)
      – writes final command output.
    * `c:exit/2` (**optional**)
      – stop the VM with an appropriate exit code.

  ## Example

  Here's an example of a typical command module:

  ```
  defmodule ExampleCmd do
    use Tux.Command

    @impl true
    def about(), do: "this command does something"

    @impl true
    def main(env, args), do: {:ok, "some result"}

    @impl true
    def help() do
      Help.new()
      |> Help.about(about())
      |> ...
      |> Help.ok()
    end
  end
  ```
  """

  @typedoc """
  A command module
  """
  @type t :: module()

  @typedoc """
  Command line arguments invoked with a command. These args will be available
  to the command module via the second parameter to the `c:main/2` callback.
  """
  @type args :: [String.t()]

  @doc """
  Return a very short command description which might be used
  when generating the help message.

      defmodule ExampleCmd do
        use Tux.Command

        @impl true
        def about(), do: "this command does something really cool"
        ...
      end
  """
  @callback about() :: String.t()

  @doc """
  Return the full help message for the command.

      defmodule ExampleCmd do
        use Tux.Command
        alias Tux.Help

        @impl true
        def help() do
          Help.new()
          |> Help.usage("mycmd", "run some command")}
          |> Help...
          |> Help.ok()
        end
      end

  You can also craft the help message as a string:

      defmodule ExampleCmd do
        use Tux.Command

        @impl true
        def help() do
          \"\"\"
          \#{bold("USAGE")}
            command [ARGS] [FLAGS]

          \#{bold("OPTIONS")}
            --flag1        This flag does something
            --flag2, -f2   This flag does something else
          \"\"\"
          |> fn msg -> {:ok, msg} end.()
        end
      end

  """
  @callback help() :: {:ok, Tux.Help.t() | String.t()}

  @doc """
  Implement the command logic.

  This callback accepts two arguments, a `Tux.Env` and a list
  of raw arguments given to the command which you can parse with
  `OptionParser`.

      defmodule ExampleCmd do
        use Tux.Command

        @impl true
        def main(env, args) do
          ... implement command and return result here
        end
      end
  """
  @callback main(env :: Tux.Env.t(), args :: args()) :: Tux.Result.t()

  @doc """
  Write the final command result to the `Tux.Env`'s device.

  Although this callback is injected whenever you `use Tux.Command`,
  it is overridable and you can implement it yourself in your own command module
  for a more custom command result printing.

      defmodule ExampleCmd do
        use Tux.Command

        @impl true
        def show(env, result) do
          case result do
            {:ok, data} -> IO.write(env.dev, data)
            _ -> IO.write(env.dev, "Something failed")
          end
        end
      end

  """
  @callback show(env :: Tux.Env.t(), result :: Tux.Result.t()) :: :ok

  @doc """
  Stop the Erlang VM using an appropriate exit code to reflect the command's
  outcome. This callback is implemented whenever you `use Tux.Command`,
  however it can be overwritten for more a custom exit logic:

      defmodule ExampleCmd do
        use Tux.Command

        @impl true
        def exit(env, result) do
          case result do
            :ok -> System.halt(0)
            :error -> System.halt(1)
          end

          # System.stop(..) – slower, graceful
          # System.halt(..) – faster, not graceful
        end
      end

  Do note that `System.stop/1` performs an asynchronous and careful stop
  of the Erlang runtime system (but takes more time), whereas `System.halt/1`
  immediately halts the runtime system, which in turn will lead to
  commands feeling snappier at the expense of graceful termination.
  """
  @callback exit(env :: Tux.Env.t(), result :: Tux.Result.t()) :: :ok | no_return()

  @optional_callbacks about: 0, help: 0, show: 2, exit: 2

  @doc """
  Implementation of the `use Tux.Command` functionality.
  """
  defmacro __using__(_opts \\ []) do
    quote do
      @behaviour Tux.Command

      alias Tux.Help
      import Tux.Colors

      use Tux.Show, overridable: true
      use Tux.Exit, overridable: true
    end
  end
end
