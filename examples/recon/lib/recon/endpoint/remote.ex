defmodule Recon.Endpoint.Remote do
  use Tux.Dispatcher

  # cmd "add", Recon.Endpoint.Remote.AddCmd
  # cmd "remove", Recon.Endpoint.Remote.RemoveCmd
  # cmd "list", Recon.Endpoint.Remote.ListCmd

  @impl true
  def about(), do: "Manage a remote endpoint"
end
