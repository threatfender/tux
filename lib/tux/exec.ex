defmodule Tux.Exec do
  @moduledoc """
  Dispatcher subystem for invoking command modules, with optional rescuing
  from raised exceptions.

  This module is injected in dispatcher at call site:

      ...
      use Tux.Exec, overrideable: true
      ...

  Of course, the injected `exec/2` function can be overwritten in
  your dispatchers:

      defmodule MyDispatcher do
        use Tux.Dispatcher

        @impl true
        def exec(env, exec_opts) do
          ... implement custom command module execution here
        end
      end
  """

  @typedoc """
  The `Tux.Env` constructed by dispatcher for an invoked command.
  """
  @type env :: Tux.Env.t()

  @typedoc """
  Execution options for command module.
  """
  @type exec_opts :: [rescue: boolean()]

  @doc """
  Invoke the command module according to the information in the `env`
  and return the result, with optional recovery from exceptions.
  """
  @callback exec(env, exec_opts) :: Tux.Result.t()

  @doc """
  Inject the `exec/2` function.
  """
  defmacro __using__(opts \\ []) do
    quote do
      @doc """
      Execute the command module and optionally recover if it fails.

      This exec function can be overwritten in your module in whic you
      do `use Tux.Dispatcher` if a more custom command execution is desired.
      """
      @spec exec(Tux.Env.t(), rescue: boolean) :: Tux.Result.t()
      def exec(env, rescue: false) do
        execute_command(env)
      end

      def exec(env, rescue: true) do
        try do
          execute_command(env)
        rescue
          error ->
            case error do
              %{__tuxexception__: _} ->
                {:error, error}

              _exception ->
                # We don't want to show the messy error to the end user, so
                # we return a tux error which explains the issue.
                {:error, Tux.Errors.CommandRescuedError.new(env: env)}
            end
        end
      end

      defp execute_command(env) do
        case env.fun do
          :help -> apply(env.mod, :help, [])
          :main -> apply(env.mod, :main, [env, env.arg])
        end
      end

      # Allow the overriding of the `exec/2` function
      if Keyword.get(unquote(opts), :overridable) do
        defoverridable exec: 2
      end
    end
  end
end
