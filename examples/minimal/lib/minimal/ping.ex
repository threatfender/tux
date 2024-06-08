defmodule Minimal.PingCmd do
  use Tux.Command

  @impl true
  def main(_env, _args),
    do: {:ok, "pong"}
end
