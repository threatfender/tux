defmodule <%= @main_module %> do
  @moduledoc """
  Documentation for `<%= @main_module %>`.
  """

  @doc """
  Delegate execution to the `<%= @main_module %>.Cli` module.
  """
  defdelegate main(args), to: <%= @main_module %>.Cli
end
