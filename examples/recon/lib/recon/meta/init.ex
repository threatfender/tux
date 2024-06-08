defmodule Recon.Meta.InitCmd do
  use Tux.Command

  @defaults %{
    dns_scans: 0,
    ssl_scans: 0,
    web_scans: 0,
    endpoints: "threatfender.com, hijackalert.com"
  }

  @impl true
  def about(), do: "Generate a default configuration file"

  @impl true
  def main(_env, _args) do
    filename = Recon.config_filename()

    with :ok <- Tux.Config.write_file!(filename, @defaults) do
      {:ok, "Initialized #{filename}"}
    end
  end
end
