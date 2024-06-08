defmodule Recon do
  @moduledoc """
  An demo app to perform some security scans.

  ## Recon Command Layout/Tree

  ```
  recon
   │─ init                - Command to create a default configuration file
   │
   │─ scan
   │    │─ dns            - Command to scan DNS records
   │    │─ ssl            - Command to scan SSL certificate
   │    └─ web            - Command to scan WEB endpoints
   │
   │─ endpoint
   │    │─ local
   │    │    │─ add       - Command to add local endpoint
   │    │    │─ remove    - Command to remove local endpoint
   │    │    └─ list      - Command to list local endpoints
   │    │
   │    └─ remote
   │         │─ add       - Command to add remote endpoint (not implemented)
   │         │─ del       - Command to remove remote endpoint (not implemented)
   │         └─ list      - Command to list remote endpoints (not implemented)
   │
   └─ usage
        │─ show           - Command to show usage stats
        └─ reset          - Command to reset usage stats
  ```

  ## Usage

  ```shell
  $ recon init

  $ recon employee list
    - Joe Doe  / $250,000
    - Jane Doe / $250,000

  $ recon employee hire --name="Mr. CEO" --salary=1,000,000
  Mr. CEO added to the organization.
  ```
  """

  defmodule Main do
    use Tux.Dispatcher

    @impl true
    def about(), do: "recon – demo security operations"

    cmd "init", Recon.Meta.InitCmd
    cmd "endpoint", Recon.Endpoint, preloads: [:config, :endpoints]
    cmd "scan", Recon.Scan, preloads: [:config, :endpoints]
    cmd "usage", Recon.Usage

    @doc """
    A preload to return the config file data
    """
    def config(_),
      do: Tux.Config.read_file!(Recon.config_filename(), keys: :atoms)

    @doc """
    Take the data from the config preload
    and return the list of endpoints.
    """
    def endpoints(env) do
      env.pre.config.endpoints
      |> String.split(",")
      |> Enum.map(&String.trim(&1))
    end
  end

  def config_filename(), do: "/tmp/recon.conf"

  @doc """
  This is the entry point of the escript.
  """
  defdelegate main(args), to: Main
end
