defmodule Tux.Errors do
  @moduledoc """
  Errors raised or returned by various tux components.

  ### Non-explainable Errors

    * `ConfigReadError`
    * `ConfigWriteError`
    * `NotImplementedError`

  ### Alertable Errors

    * `CommandRescuedError`
    * `CommandNotFoundError`
  """

  defmodule ConfigReadError do
    @moduledoc false
    defexception [:message]
  end

  defmodule ConfigWriteError do
    @moduledoc false
    defexception [:message]
  end

  defmodule NotImplementedError do
    @moduledoc false
    defexception [:message]
  end

  defmodule CommandRescuedError do
    @moduledoc false
    use Tux.Error, message: "Command Failure"

    @doc """
    Return a new error for the current command.
    """
    def new(env: env) do
      msg = "The #{bold(env.cmd)} command has filed."
      info = "Use #{bold("--debug")} to see error stacktrace."
      %__MODULE__{details: "#{msg} #{info}"}
    end
  end

  defmodule CommandNotFoundError do
    @moduledoc false
    use Tux.Error, message: "Command not found"

    @doc """
    Construct a new error explaining which command is missing.
    """
    def new(name: name) do
      %__MODULE__{details: "The `#{name}` command does not exist."}
    end
  end
end
