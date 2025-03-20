defmodule <%= @main_module %>.Cli do
  @moduledoc """
  Dispatch execution to the appropriate command module
  based on the current command name.
  """
  use Tux.Dispatcher

  @impl true
  def about(), do: "My program"

  def user(_env) do
    System.get_env("USER")
  end

  cmd "ping", __MODULE__.Ping
  cmd ~w(h hello), __MODULE__.Hello, preloads: [:user]
end
