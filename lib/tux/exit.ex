defmodule Tux.Exit do
  @moduledoc """
  Routines for stopping the VM with an appropriate exit code
  from command modules.

  This logic in this module is automatically injected by dispatcher and
  command modules, however its callbacks can be overwritten for custom needs:

      defmodule MyCmd do
        use Tux.Command

        @impl true
        def exit(env, result), do: ...stop the VM...
      end

  """

  @doc """
  Shutdown the VM using an exit code extracted or derived
  from the given command result.
  """
  @callback exit(env :: Tux.Env.t(), result :: Tux.Result.t()) :: :ok | no_return()

  @doc """
  Return the correponding exit code for a given command result.

  The returned exit code will be determined from the given result value,
  which ought to be following the `Tux.Result` format, however when non-`Tux.Result`
  values are given, the exit code will always be determined to be 0.

  ## Examples

      iex> Tux.Exit.code(:ok)
      0

      iex> Tux.Exit.code({:ok, "some term"})
      0

      iex> Tux.Exit.code(:error)
      1

      iex> Tux.Exit.code({:error, %{exitcode: 10}})
      10

      iex> Tux.Exit.code({:error, "some error"})
      1

      iex> Tux.Exit.code(:anything_else_returns_0)
      0

  """
  @spec code(result :: Tux.Result.t()) :: integer() | no_return()
  def code(:ok), do: 0
  def code({:ok, _}), do: 0

  def code(:error), do: 1
  def code({:error, %{exitcode: code}}), do: code
  def code({:error, _}), do: 1

  def code(_non_standard_result), do: 0

  defmacro __using__(opts \\ []) do
    quote do
      alias Tux.Env
      alias Tux.Result

      @doc """
      Implementation for the `c:Tux.Exit.exit/2` callback.
      """
      @spec exit(Env.t(), Result.t()) :: :ok | no_return()
      def exit(env, result), do: _exit(env, Tux.Exit.code(result))

      if Keyword.get(unquote(opts), :overridable) do
        defoverridable exit: 2
      end

      if Mix.env() == :test do
        def _exit(_, code), do: :ok
      else
        def _exit(env, code), do: apply(System, env.ext, [code])
      end
    end
  end
end
