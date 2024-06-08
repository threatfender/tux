defmodule Recon.Scan do
  use Tux.Dispatcher

  @preloads usage: {Recon.Scan.Track, :usage, []}

  pre @preloads do
    cmd "dns", Recon.Scan.DNSCmd
    cmd "ssl", Recon.Scan.SSLCmd
    cmd "web", Recon.Scan.WEBCmd
  end

  @impl true
  def about(), do: "Scan endpoints"

  defmodule Track do
    defp int!(s), do: Integer.parse(s) |> elem(0)

    @doc """
    Count and store scans
    """
    def usage(env) do
      cmd_to_key = %{
        "dns" => :dns_scans,
        "ssl" => :ssl_scans,
        "web" => :web_scans
      }

      config =
        Map.update(env.pre.config, Map.fetch!(cmd_to_key, env.cmd), 0, fn n -> int!(n) + 1 end)

      Recon.config_filename()
      |> Tux.Config.write_file(config)
    end
  end
end
