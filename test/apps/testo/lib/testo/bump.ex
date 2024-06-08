defmodule Testo.BumpDsp do
  @moduledoc false
  use Tux.Dispatcher, preloads: [:zero]
  def zero(_), do: 0

  defmodule Bump3Cmd do
    @moduledoc false
    alias __MODULE__, as: Preloads

    use Tux.Dispatcher, preloads: [one: {Preloads, :inc, [:zero]}]
    def inc(env, prev), do: env.pre[prev] + 1

    defmodule BumpCmd do
      @moduledoc false
      use Tux.Command
      def main(env, _), do: {:ok, "#{env.pre.three}"}
    end

    pre two: {Preloads, :inc, [:one]} do
      cmd "bump", BumpCmd, preloads: [three: {Preloads, :inc, [:two]}]
    end
  end

  cmd "bump", Bump3Cmd
end
