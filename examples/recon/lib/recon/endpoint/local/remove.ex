defmodule Recon.Endpoint.Local.RemoveCmd do
  use Tux.Command

  @impl true
  def main(env, args) do
    {parsed, _, _} = OptionParser.parse(args, strict: [name: :string])

    case Keyword.get(parsed, :name) do
      nil -> {:error, "--name required"}
      endpoint -> remove_endpoint(env.pre.config, endpoint)
    end
  end

  def remove_endpoint(config, endpoint) do
    config =
      case config.endpoints do
        "" ->
          config

        str ->
          str
          |> String.split(",")
          |> Enum.map(&String.trim(&1))
          |> Kernel.--([endpoint])
          |> Enum.join(", ")
          |> (fn new_str -> Map.put(config, :endpoints, new_str) end).()
      end

    :ok = Tux.Config.write_file(Recon.config_filename(), config)
    {:ok, "Endpoint `#{endpoint}` removed"}
  end
end
