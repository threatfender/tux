defmodule Recon.Usage do
  use Tux.Dispatcher

  @impl true
  def about(), do: "Show usage statistics"

  pre config: {Recon.Main, :config, []} do
    cmd "show", Recon.Usage.Show
    cmd "reset", Recon.Usage.Reset
  end
end
