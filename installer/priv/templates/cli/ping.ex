defmodule <%= @main_module %>.Cli.Ping do
  use Tux.Command

  @impl true
  def about(), do: "Show pong"

  @impl true
  def main(_env, _args) do
    {:ok, "pong"}
  end

  @impl true
  def help() do
    Help.new()
    |> Help.about(about())
    |> Help.ok()
  end
end
