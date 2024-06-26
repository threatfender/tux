defmodule Tux.Quick do
  @moduledoc """
  Utility macros for generating hierarchical, compact skeletons of simple programs
  used for testing purposes without going the traditional route of creating
  the modules with `Tux.Dispatcher`, `Tux.Command`, etc.

    * `program/2`    - generate a top level dispatcher module
    * `program/1`    - return the Elixir module name generated by `program/2`
    * `dispatcher/2` - generate and register a dispatcher module
      with a given name, inside a parent dispatcher
    * `command/2`    - generate and register a command module
      with a given name

  ## Example

  Here's an example of a simple CLI tool built using this module's macros:

      defmodule Tool do
        import Tux.Quick

        program "cli" do
          command "hello", do: {:ok, "hello world"}

          dispatcher "ping" do
            command "once", do: {:ok, "pong"}
            command "twice", do: {:ok, "pong pong"}
          end
        end

        defdelegate main(args), to: program("cli")
      end

  Update your `mix.exs` to define the escript, build it with `mix escript.build`,
  and then finally run it:

  ```
  $ mix escript.build

  $ ./tool hello
  hello

  $ ./tool ping once
  pong

  $ ./tool ping twice
  pong pong
  ```
  """

  @doc since: "0.3.0"

  @doc """
  Construct a `Tux.Command` module inside a dispatcher module.

      command "ping" do
        {:ok, "pong"}
      end

  You can also supply the registration options you'd normally supply
  to the `Tux.Dispatcher.cmd/3` macro:

      command "ping", preloads: [...] do
        {:ok, "pong"}
      end
  """
  defmacro command(name, opts \\ [], do: block) do
    quote do
      # 1. Construct a command module
      defmodule program(unquote(name)) do
        use Tux.Command

        @impl true
        def main(env, args) do
          unquote(block)
        end
      end

      # 2. Register command module for given command on current dispatcher
      cmd unquote(name), program(unquote(name)), unquote(opts)
    end
  end

  @doc since: "0.3.0"

  @doc """
  Construct a `Tux.Dispatcher` module and register it with the given name as
  a command module within the context of its parent dispatcher.

      dispatcher "foo" do
        command "ping", do: {:ok, "pong"}
      end

  This macro also accepts the usual `Tux.Dispatcher` options:

      dispatcher "foo", rescue: true, ... do
        ...
      end
  """
  defmacro dispatcher(name, opts \\ [], do: block) do
    quote do
      defmodule program(unquote(name)) do
        use Tux.Dispatcher, unquote(opts)

        unquote(block)
      end

      cmd unquote(name), program(unquote(name)), unquote(opts)
    end
  end

  @doc since: "0.3.0"

  @doc """
  Construct a top-level dispatcher module with no registered commands,
  inside which you can define other tux structures such as dispatchers
  and commands using the `dispatcher/2` and `command/2` macros.

      program "foo" do
        dispatcher "bar" do
          command "ping", do: {:ok, "pong"}
        end
      end

  This macro also accepts the usual `Tux.Dispatcher` options:

      program "foo", rescue: true do
        ...
      end

  To return the name of module generated with this macro use `program/1`.
  """
  defmacro program(name, opts \\ [], do: block) do
    quote do
      defmodule program(unquote(name)) do
        use Tux.Dispatcher, unquote(opts)

        unquote(block)
      end
    end
  end

  @doc since: "0.4.0"

  @doc """
  Return the name of a module which was created with `program/2`:

      iex> import Tux.Quick
      ...> program("mytool")
      :"Elixir.mytool"

      iex> import Tux.Quick
      ...> program(:another)
      :"Elixir.another"

  """
  defmacro program(name) do
    quote do
      Module.concat([unquote(name)])
    end
  end
end
