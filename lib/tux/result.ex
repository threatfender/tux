defmodule Tux.Result do
  @moduledoc """
  The tux result is the standard result type which must be returned by a command module,
  which controls what the CLI's end-user sees as output.

  | Result Value    | Meaning   | Command Output Behaviour                                                  |
  |-----------------|-----------|---------------------------------------------------------------------------|
  | `:ok`           | Success   | nothing will be shown                                                     |
  | `:error`        | Failure   | a `Tux.Alert` will be shown                                               |
  | `{:ok, term}`   | Success   | `term` will be shown (`term` must implement `String.Chars`).              |
  | `{:error, term}`| Failure   | a `Tux.Alert` (red)    will be shown (`term` must implement `Tux.Alertable`) |

  ## Non-standard Results

  You can also return anything else you like from a command, in which case you need
  to implement your own `show/2` callback in your command module to instruct tux
  how to print your command's results.

  There are some caveats to returning non-standard command results (see below),
  however, case need be, here's an example of how you could do it:

      defmodule Cli do
        use Tux.Dispatcher

        defmodule AddCmd do
          @impl true
          def about(), do: "Add a list of numbers"

          @impl true
          def main(_env, args) do
            args
            |> Enum.map(&parse/1)
            |> Enum.reject(fn value -> value == :error end)
            |> Enum.sum()
          end

          defp parse(string) do
            case Integer.parse(string) do
              {num, ""} -> num
              _ -> :error
            end
          end

          @impl true
          def show(env, result) do
            case "--json" in env.raw do
              true ->
                  %{result: result}
                  |> to_json_string()
                  |> IO.puts()
              false ->
                  IO.puts(result)
            end
          end
        end

        cmd "add", AddCmd
      end

      defmodule Math do
        def main(args), do: Cli.main(args)
      end

  ```sh
  $ ./math add 1 2 3 4
  {"result": 10}
  ```

  ## Caveats for Non-standard Results

  Tux determines your escript's exit code based on any given command's return value
  if it follows the `Tux.Result` format, otherwise the exit code will always be 0
  – see `Tux.Exit` – which might not be what you want if you want to signal a program error.

  Of course, along with your custom `show/2` implementation you can also implement
  a custom `exit/2` which checks the result and stops the VM with an appropriate code.
  Here's an implementation extending the above example, which for fun
  sets the escript's exit code to the computed sum value:

      defmodule AddCmd do
        use Tux.Command

        ...

        @impl true
        def exit(env, result) do
          System.halt(result)
          # or
          # apply(System, env.ext, [result])
        end
      end

  """

  @typedoc """
  The final result returned by a command
  """
  @type t :: :ok | :error | {:ok, String.Chars.t()} | {:error, Tux.Alertable.t()}

  import Tux.Colors

  @doc """
  A utility function for raising a RuntimeError with detailed information
  about a non-standard command return value.
  """
  def raise_invalid_result_type(env, term) do
    target_module = underline(Macro.to_string(env.mod))
    target_full = underline("#{Macro.to_string(env.mod)}.#{env.fun}(...)")

    details = """
    #{red("RUNTIME ERROR: Non-standard command result")}
      The result #{underline(inspect(term))} returned by #{target_full}
      registered for the command `#{env.cmd}` does not conform to the Tux.Result shape
    """

    suggestions = """
    #{orange("Possible Fixes")}
      1. Ensure #{target_full} returns one of the following:
         - #{blue(":ok")}
         - #{blue(":error")}
         - #{blue("{:ok, String.Chars.t() | Alertable.t()}")}
         - #{blue("{:error, String.Chars.t() | Alertable.t()}")}

      2. Consider implementing your own `show(env, result)` function inside #{target_module}
      which will handle writing the command result.
    """

    hints = """
    #{orange("Read the docs")}
        - For standard command return values see #{blue("Tux.Result")}
        - For alert-able results see #{blue("Tux.Alertable")}
    """

    raise %RuntimeError{
      message: """

      ============================================================================

      #{details}
      #{suggestions}
      #{hints}
      ============================================================================
      """
    }
  end
end
