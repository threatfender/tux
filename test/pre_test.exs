defmodule Tux.PreTest do
  use Tux.Case

  defmodule Program do
    use Tux.Dispatcher

    def foo(_), do: :foo
    def bar(_), do: :bar

    defmodule Hello1 do
      use Tux.Command

      def main(env, _) do
        {:ok, "foo=#{env.pre.foo}"}
      end
    end

    defmodule Hello2 do
      use Tux.Command

      def main(env, _) do
        {:ok,
         "foo=#{env.pre.foo} bar=#{env.pre.bar} x=#{env.pre.x} y=#{env.pre.y} z=#{env.pre.z}"}
      end
    end

    defmodule Utils do
      def zar(_), do: :zar
    end

    # pre with multiple lines (:__block__)
    pre [:foo] do
      cmd "hello1", Hello1

      cmd "hello2", Hello2,
        preloads: [
          :bar,
          x: {Utils, :zar, []},
          y: {Utils, :zar, []},
          z: :bar
        ]
    end

    # pre with a single line (not a :__block__)
    pre [:foo] do
      cmd "hello1s", Hello1
    end

    # pre with a single line (not a :__block__)
    pre [:foo] do
      cmd "hello2s", Hello2,
        preloads: [
          :bar,
          x: {Utils, :zar, []},
          y: {Utils, :zar, []},
          z: :bar
        ]
    end
  end

  scenario "pre",
    using: Program,
    invoke: "hello1",
    expect: [exactly: "foo=foo\n"]

  scenario "pre + cmd preloads",
    using: Program,
    invoke: "hello2",
    expect: [exactly: "foo=foo bar=bar x=zar y=zar z=bar\n"]

  scenario "pre (single line)",
    using: Program,
    invoke: "hello1s",
    expect: [exactly: "foo=foo\n"]

  scenario "pre + cmd preloads (single line)",
    using: Program,
    invoke: "hello2s",
    expect: [exactly: "foo=foo bar=bar x=zar y=zar z=bar\n"]

  describe "nested preloads" do
    defmodule BumpCli do
      use Tux.Dispatcher, preloads: [zero: :inc]
      def inc(_), do: 0

      defmodule Dsp do
        use Tux.Dispatcher, preloads: [one: {Dsp, :inc, [:zero]}]
        def inc(env, prev), do: env.pre[prev] + 1

        defmodule Cmd do
          use Tux.Command
          def main(env, _), do: {:ok, "#{env.pre.three}"}
        end

        pre two: {Dsp, :inc, [:one]} do
          cmd "bump", Cmd, preloads: [three: {Dsp, :inc, [:two]}]
        end
      end

      cmd "bump", Dsp
    end

    scenario "nested preloads from all levels",
      using: BumpCli,
      invoke: "bump bump bump",
      expect: [exactly: "3\n"]
  end
end
