defmodule Minimal do
  defmodule Cli do
    use Tux.Dispatcher

    cmd "ping", Minimal.PingCmd
    cmd "hello", Minimal.HelloCmd, preloads: [:user]

    def user(_env), do: System.get_env("USER")
  end

  @doc "Delegate escript entry point to Cli"
  defdelegate main(args), to: Cli
end
