defmodule Testo.PingCmd do
  @moduledoc false
  use Tux.Command

  @impl true
  def main(_, _), do: {:ok, "pong"}
end
