defmodule <%= @main_module %>.Cli.Hello do
  use Tux.Command

  @impl true
  def about(), do: "Greet current user"

  @impl true
  def main(env, _args) do
    {:ok, "Hello, #{env.pre.user}"}
  end

  @impl true
  def help() do
    Help.new()
    |> Help.about(about())
    |> Help.ok()
  end
end
