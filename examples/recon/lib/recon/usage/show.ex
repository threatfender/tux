defmodule Recon.Usage.Show do
  use Tux.Command

  @impl true
  def about(),
    do: "Show organization stats"

  @impl true
  def main(env, _args) do
    text = """
    #{bold("STATS:")}
      DNS Scans: #{env.pre.config.dns_scans}
      SSL Scans: #{env.pre.config.ssl_scans}
      WEB Scans: #{env.pre.config.web_scans}

    #{bold("NOTES:")}
      To reset, type #{green("recon usage reset")}
    """

    {:ok, text}
  end
end
