defmodule Recon.Endpoint.Local.ListCmd do
  use Tux.Command

  @impl true
  def main(env, _args) do
    env.pre.endpoints
  end

  @impl true
  def show(env, endpoints) do
    if "--json" in env.arg do
      endpoints
      |> Jason.encode!()
      |> IO.puts()
    else
      endpoints
      |> Enum.map(&Kernel.<>(" - ", &1))
      |> Enum.join("\n")
      |> IO.puts()
    end
  end
end
