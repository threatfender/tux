defmodule Tux.Init do
  @moduledoc """
  Dispatcher subsystem used internally for initialization of command environment
  and collection of preload results prior to command execution.
  """

  @doc """
  Initialize a new command environment from *preloads*
  and *command line arguments*.
  """
  @callback init(map(), [String.t()]) :: Tux.Env.t()

  @doc """
  This is used internally by the `Tux.Dispatcher` to inject the init routines.
  """
  defmacro __using__(opts \\ []) do
    quote do
      alias Tux.Env

      # Build a new environment struct and populate certain fields
      # with the values extracted from the parent dispatcher
      defp build_env(raw, cmd, mod, fun, pre, arg) do
        Env.new()
        |> Env.add(:raw, raw)
        |> Env.add(:cmd, cmd)
        |> Env.add(:mod, mod)
        |> Env.add(:fun, fun)
        |> Env.add(:pre, pre)
        |> Env.add(:arg, arg)
        |> Env.add(:dev, device())
        |> Env.add(:dsp, __MODULE__)
        |> Env.add(:new, newlines?())
        |> Env.add(:ext, exitwith())
      end

      @doc """
      Initialize a new `Tux.Env` structure.

      This function performs a few initialization steps, such as:

        * Locate the command module for the command name
        * Execute the associated command preloads and capture results
        * Construct the `Tux.Env` struct
        * Subtract command name from the args
      """
      @spec init(map(), Env.raw()) :: Env.t()
      def init(pre, []) when is_map(pre) do
        # Receiving no arguments is the equivalent of
        # requesting the "" (empty) command.
        build_env([], "", __MODULE__, :help, pre, [])
      end

      def init(pre, [cmd, arg] = raw) when arg in ~w(-h --help) and is_map(pre) do
        case Tux.Locator.locate_cmd_module(cmds(), cmd) do
          {:ok, {{_, _}, mod, opts}} ->
            build_env(raw, cmd, mod, :help, pre, [])
            |> exec_preloads(get_preloads(opts))

          {:error, :cmd_undefined} ->
            build_env(raw, cmd, :not_found, :help, pre, [])
        end
      end

      def init(pre, [cmd | args] = raw) when is_map(pre) do
        case Tux.Locator.locate_cmd_module(cmds(), cmd) do
          {:ok, {{_, _}, mod, opts}} ->
            build_env(raw, cmd, mod, :main, pre, args)
            |> exec_preloads(get_preloads(opts))

          {:error, :cmd_undefined} ->
            build_env(raw, cmd, :not_found, :main, pre, args)
        end
      end

      # Return both the dispatcher's and the command's preload lists
      defp get_preloads(cmd_registration_opts),
        do: __MODULE__.preloads() ++ Keyword.get(cmd_registration_opts, :preloads, [])

      @doc """
      Execute preload functions and collect the results into a map
      keyed by either the preload's function name or a custom key
      if one was specified when the preload was declared.
      """
      @spec exec_preloads(Env.t(), [Env.mfn()]) :: Env.arg()
      def exec_preloads(env, []) do
        env
      end

      def exec_preloads(%Env{} = env, funs) when is_list(funs) do
        Enum.reduce(funs, env, fn fun, acc ->
          case fun do
            # Function is the {name, mfa} tuple
            {name, {mod, fun, args}} when is_list(args) ->
              %{acc | pre: Map.put(acc.pre, name, apply(mod, fun, [acc] ++ args))}

            # Function is the {name, tom} tuple
            {name, fun} when is_atom(name) and is_atom(fun) ->
              %{acc | pre: Map.put(acc.pre, name, apply(__MODULE__, fun, [acc]))}

            # Function is just an atom
            name when is_atom(name) ->
              %{acc | pre: Map.put(acc.pre, name, apply(__MODULE__, name, [acc]))}
          end
        end)
      end

      if Keyword.get(unquote(opts), :overridable) do
        defoverridable init: 2
      end
    end
  end
end
