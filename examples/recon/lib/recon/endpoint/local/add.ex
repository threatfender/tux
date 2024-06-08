defmodule Recon.Endpoint.Local.AddCmd do
  use Tux.Command

  @impl true
  def main(env, args) do
    {parsed, _, _} = OptionParser.parse(args, strict: [name: :string])

    case Keyword.get(parsed, :name) do
      nil -> {:error, "--name required"}
      endpoint -> add_endpoint(env.pre.config, endpoint)
    end
  end

  def add_endpoint(config, endpoint) do
    config =
      case config.endpoints do
        "" -> Map.put(config, :endpoints, endpoint)
        str -> Map.put(config, :endpoints, "#{str}, #{endpoint}")
      end

    :ok = Tux.Config.write_file(Recon.config_filename(), config)
    {:ok, "Endpoint `#{endpoint}` added"}
  end
end
