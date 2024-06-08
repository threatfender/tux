defmodule Tux.PreSubcmdTest do
  use Tux.Case

  defmodule Program do
    use Tux.Dispatcher

    defmodule EndSubcmd do
      use Tux.Command

      def main(env, _),
        do:
          {:ok,
           env.pre.one +
             env.pre.p2a +
             env.pre.p2b +
             env.pre.p3a +
             env.pre.p3b}
    end

    defmodule MiddleSubcmd do
      use Tux.Dispatcher
      def three(_), do: 3

      pre p3a: :three do
        cmd "end", EndSubcmd, preloads: [p3b: :three]
      end
    end

    defmodule StartCmd do
      use Tux.Dispatcher
      def two_x_1(_), do: 2
      def two_x_n(_, n), do: 2 * n

      cmd "middle", MiddleSubcmd,
        preloads: [
          p2a: {Tux.PreSubcmdTest.Program.StartCmd, :two_x_1, []},
          p2b: {Tux.PreSubcmdTest.Program.StartCmd, :two_x_n, [2]}
        ]
    end

    def one(_), do: 1
    cmd "start", StartCmd, preloads: [:one]
  end

  scenario "preloads accumulate across command hierarchies",
    using: Program,
    invoke: "start middle end",
    expect: [exactly: "13\n"]
end
