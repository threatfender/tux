defmodule Recon.Scan.DNSCmd do
  use Tux.Command

  @impl true
  def about(), do: "Scan DNS records for a endpoint"

  @impl true
  def main(env, _args) do
    env.pre.endpoints
    |> Enum.map(fn e -> "[DNS] #{e} #{green("[ok]")}" end)
    |> Enum.join("\n")
    |> (fn contents -> {:ok, contents} end).()
  end

  @impl true
  def help() do
    Help.new()
    |> Help.about(about())
    |> Help.usage([
      {"scan dns", "Scan DNS for all endpoints"}
    ])
    |> Help.ok()
  end
end
