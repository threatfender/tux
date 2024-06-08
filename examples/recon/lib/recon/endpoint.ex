defmodule Recon.Endpoint do
  use Tux.Dispatcher

  cmd "local", Recon.Endpoint.Local
  cmd "remote", Recon.Endpoint.Remote

  @impl true
  def about(), do: "endpoint - add or remove endpoints"
end
