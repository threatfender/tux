defmodule Recon.Usage.Reset do
  use Tux.Command

  @impl true
  def about(),
    do: "Reset command usage stats"

  @impl true
  def main(env, _args) do
    env.pre.config
    |> (fn config -> %{config | dns_scans: 0} end).()
    |> (fn config -> %{config | ssl_scans: 0} end).()
    |> (fn config -> %{config | web_scans: 0} end).()
    |> (fn config -> Tux.Config.write_file(Recon.config_filename(), config) end).()
    |> case do
      :ok ->
        {:ok, "Done"}

      {:error, error} ->
        {:error,
         %Tux.Error{
           message: "Cannot reset usage",
           details: """
           Error details: #{inspect(error)}
           """
         }}
    end
  end
end
