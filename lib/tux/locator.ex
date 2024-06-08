defmodule Tux.Locator do
  @moduledoc """
  Find the command module for a given command name.
  """

  @type cmd_regname :: {:exact | :prefix, String.t()}
  @type cmd_module :: Tux.Command.t()
  @type cmd_opts :: keyword()

  @typedoc """
  Command definition as registered with its dispatcher
  """
  @type cmd_def :: {cmd_regname(), cmd_module(), cmd_opts()}

  @typedoc """
  Returned error messages
  """
  @type locate_err_msg :: :cmd_conflict | :cmd_undefined

  @typedoc """
  Command name given to the CLI
  """
  @type cmd_name :: String.t()

  @doc """
  Locate the corresponding command module associated with a given
  command name which was typed at the command line.
  """
  @spec locate_cmd_module([cmd_def], cmd_name) :: {:ok, cmd_def} | {:error, locate_err_msg}
  def locate_cmd_module(cmd_defs, cmd_name) do
    cmd_defs
    |> Enum.filter(fn {head, _module, _opts} ->
      case head do
        {:exact, name} ->
          cmd_name == name

        {:prefix, prefix} ->
          String.starts_with?(cmd_name, prefix)
      end
    end)
    |> case do
      [cmd_def] ->
        {:ok, cmd_def}

      [_, _ | _] ->
        {:error, :cmd_conflict}

      [] ->
        {:error, :cmd_undefined}
    end
  end
end
