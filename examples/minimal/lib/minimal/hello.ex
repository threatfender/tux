defmodule Minimal.HelloCmd do
  use Tux.Command

  @impl true
  def about(),
    do: "Greet the current shell user"

  @impl true
  def main(env, _args),
    do: {:ok, "Hello there, #{env.pre.user}!"}
end
