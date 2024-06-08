defmodule Recon.Scan.WEBCmd do
  use Tux.Command

  @impl true
  def about(), do: "Scan WEB status for a endpoint"

  @impl true
  def main(env, _args) do
    env.pre.endpoints
    |> Enum.map(fn e -> "[WEB] #{e} #{green("[ok]")}" end)
    |> Enum.join("\n")
    |> (fn contents -> {:ok, contents} end).()
  end

  @impl true
  def help() do
    Help.new()
    |> Help.about(about())
    |> Help.usage([
      {"scan dns", "Scan WEB for all endpoints"}
    ])
    |> Help.ok()
  end
end
