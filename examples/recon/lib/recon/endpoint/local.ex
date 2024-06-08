defmodule Recon.Endpoint.Local do
  use Tux.Dispatcher

  cmd "add", Recon.Endpoint.Local.AddCmd
  cmd "remove", Recon.Endpoint.Local.RemoveCmd
  cmd "list", Recon.Endpoint.Local.ListCmd

  @impl true
  def about(), do: "Manage a local endpoint"
end
