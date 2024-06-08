defmodule Recon.Scan.SSLCmd do
  use Tux.Command

  @impl true
  def about(), do: "Scan SSL certificate for a endpoint"

  @impl true
  def main(env, _args) do
    env.pre.endpoints
    |> Enum.map(fn e -> "[SSL] #{e} #{green("[ok]")}" end)
    |> Enum.join("\n")
    |> (fn contents -> {:ok, contents} end).()
  end

  @impl true
  def help() do
    Help.new()
    |> Help.about(about())
    |> Help.usage([
      {"scan dns", "Scan SSL for all endpoints"}
    ])
    |> Help.ok()
  end
end
