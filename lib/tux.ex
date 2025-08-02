defmodule Tux do
  @moduledoc """
  *Terminal User Experience*

  [`tuxpkg.dev ›`](https://tuxpkg.dev/)
  [`github.com ›`](https://github.com/threatfender/tux/)

  Tux is a **modular**, **dependency-free** Elixir library
  designed for the speedy creation of elegant command line interfaces
  which subscribe to the philosophy *"One module per command"*.

  Its modular structure ensures its core functionalities can be overwritten
  and composed to fulfill custom needs, and having no dependencies means
  it can achieve a higher level of security by minimizing trusted parties.

  _NOTE_: To bootstrap a new tux-based CLI Elixir project, use the
  [tux_new](https://hex.pm/packages/tux_new) generator available
  on [Hex](https://hex.pm):

  ```shell
  $ mix do archive.install hex tux_new + tux.new myapp
  ```

  ## Features

  Developing with the tux library involves typically the use of
  the following featured modules:

  - `Tux.Dispatcher` - command registration and dispatch macros
  - `Tux.Command`    - command module behaviour
  - `Tux.Result`     - shapes for the command results
  - `Tux.Prompt`     - basic user prompting and answer parsing
  - `Tux.Error`      - user friendly error messages
  - `Tux.Config`     - reading and writing of simple configuration files
  - `Tux.Help`       - command help message construction
  - `Tux.Case`       - command testing macros

  ## Installation

  Add `tux` to your list of dependencies in `mix.exs` and optionally update
  your `.formatter.exs`:

  ```
  # mix.exs
  {:tux, "~> 0.4.0"}

  # .formatter.exs
  import_deps: [:tux]
  ```

  ## Examples

  Here's a very short example to illustrate the mechanics of the library:

  1. A **command module** implements the command:

  ```elixir
  defmodule Demo.HelloCmd do
    use Tux.Command

    @impl true
    def about(), do: "Greet current user"

    @impl true
    def main(env, args), do: {:ok, "Hello \#{env.pre.user}!"}
  end
  ```

  2. A **dispatcher module** associates command names with command modules,
  or groups them as sub-commands:

  ```elixir
  defmodule Demo do
    use Tux.Dispatcher

    # Command registration (with options)
    cmd "hello", Demo.HelloCmd, preloads: [:user]

    # A preload function can run prior to command execution
    def user(env), do: System.fetch_env!("USER")
  end
  ```

  3. **Build** your elixir app as an escript executable. Note that you need to
  update your `mix.exs` to reflect your escript's main module.
  See [mix escript.build](https://hexdocs.pm/mix/main/Mix.Tasks.Escript.Build.html)
  for more details.

  ```
  # mix.exs
  def project do
    [
      escript: [main_module: Demo]
      ...
    ]
  end
  ```

  Generate the escript executable:

  ```
  $ mix escript.build
  Generated escript demo

  $ ./demo hello
  Hello tuxuser!
  ```

  4. **Extend** your app with new commands simply by creating new
  command modules, then register them with the dispatcher:

  ```elixir
  defmodule Demo.AddCmd do
    use Tux.Command

    @impl true
    def main(env, [x, y]) do
      {a, ""} = Integer.parse(x)
      {b, ""} = Integer.parse(x)
      {:ok, "\#{a} + \#{b} = \#{a+b}"}
    end
  end
  ```

  Register the *Demo.AddCmd* module under the *"add"* name:

  ```elixir
  defmodule Demo do
    ...
    cmd "add", Demo.AddCmd
    cmd "hello", Demo.HelloCmd, preloads: [:user]
  end
  ```

  Rebuild the escript then run:

  ```sh
  $ mix escript.build
  $ ./demo add 1 2
  1 + 2 = 3
  ```

  ## Overview

  Tux was designed to be modular and dependency-free, all the while leveraging
  the powerful Elixir macro system to enable the development of command line
  interfaces with ease.

  ### 0. Concepts

  Here's a summary of some the concepts used throughout the tux universe:

    * *Command* – some functionality implemented by an executable.
    * *Command Name* – some keyword which identifies a command.
    * *Command Module* – a specialized module which implements a given command.
    * *Command Dispatcher* – a specialized module responsible for grouping commands
      and for delegating program execution to the appropriate command module
      in response to command invocations.
    * *Command Preloads* – optional functions dispatchers can execute prior to
      executing commands, and whose results are made available to the command modules
      as part of their environment.

  ### 1. Commands

  Commands expose the functionality of your program/escript to the end user.
  They are invoked using keywords (command names), as part of your
  program/escript invocation.

  By analogy, when you make use of the `mix` program and type `mix compile`,
  you invoke the *compile* command of the *mix* program.

  To implement commands using tux, you create *command modules* which
  contain the business logic, then group them together under one or more
  dispatchers.

  Here's a the most minimal example of a command module created with tux:

  ```
  defmodule PingCmd do
    use Tux.Command

    @impl true
    def main(env, args) do
      {:ok, "pong"}
    end
  end
  ```

  Command modules can implement other callbacks besides the `c:Tux.Command.main/2`.
  See the `Tux.Command` behaviour for more details.

  Alright, so now that we have just implemented a command, how can we connect it
  to the rest of the escript? Enter dispatchers:

  ### 2. Dispatchers

  ```
  Dispatcher Module
     ├─── Command Module
     ├─── Command Module
     └─── Dispatcher Module
              ├─── Command Module
              └─── Command Module
  ```

  Dispatchers are modules which contain the mappings `command names -> command modules`
  and are responsible for delegating execution to the appropriate command module
  in response to a command invocation.


  Well, they actually do a little more than that, among which collecting the results
  from command preloads, setting up the command context, recovering
  from exceptions and more.

  A dispatcher's functionality is implemented by the `Tux.Dispatcher` module, and it can
  be injected into your own dispatcher modules via the `__using__` macro.
  Here's an example of a dispatcher which associates the *ping* command
  with the `PingCmd` module we've just implemented:

      defmodule MyProgram do
        use Tux.Dispatcher

        # Register a new command module via a command name
        cmd "ping", PingCmd

        # Alternatively a command module can be registered under multiple
        # names at once (useful for command shortcuts)
        cmd ~w"pong p", PongCmd
      end

  **Customizing Dispatchers** – Please read the section
  [Dispatcher Options](Tux.Dispatcher.html#module-dispatcher-options) for how to
  customize a dispatcher's behaviour.

  ### 3. Dispatcher & Command Preloads

  Oftentimes, commands need to obtain some data or run some business logic prior
  to the actual command execution, so to help with these aspects tux offers *preloads*.

  Preloads are functions a dispatcher can execute prior to command execution,
  and whose results can be made available to the command module in the `env` struct,
  which is the first argument pass to the command module's `c:Tux.Command.main/2`
  callback.

  For illustrative purposes, let's update our ping command with a preload which
  can return the current datetime and make that available in the command output:

  Here's the updated dispatcher module and command registration:

      defmodule MyProgram do
        use Tux.Dispatcher

        @doc "A preload function to return the current datetime"
        def date(_env), do: DateTime.utc_now()

        # Command registered with preload
        cmd "ping", PingModule, preloads: [:date]
      end

  And here's the command module making use of the preload's result:

      defmodule PingCmd do
        use Tux.Command

        @impl true
        def main(env, args) do
          {:ok, "pong \#{date}"}
        end
      end

  ```
  $ mix escript.build
  $ ./program ping
  pong 2024-06-07 20:36:56.687017Z
  ```
  ### 4. Results

  Command modules should return the following results:

    * `:ok`
    * `:error`
    * `{:ok, String.Chars.t()}`
    * `{:error, String.Chars.t() | Tux.Alertable.t()}`

  Please sees `String.Chars` and `Tux.Alertable` protocols for more details.

  ### 5. Errors

  To signal a command has failed you can return a `Tux.Result` error tuple containing a
  a `Tux.Error` (or a string message) value. In such a case, this value will be converted
  and displayed nicely as a `Tux.Alert`.

  Now, if the business logic of a command is deeply nested, it might be easier to
  simply raise an exception from the depths of your code, with the downside of having
  the end user see the entire stacktrace (which might not be an issue for
  other developers), but nonetheless it can be unsightly.

  With tux, you can rescue from command exceptions and display alerts instead. To this
  end, you need to construct the dispatcher module with the `rescue: true` option, and
  as a consequence, command exceptions will be shown more elegantly while still
  preserving the ability to view the entire stacktrace when the command is invoked
  with the `--debug` flag.

  **Exit Codes** – A `Tux.Error` also contains an `exitcode` field, which you can
  overwrite, and it will be used as the program/escript's exit status.

  ### 6. Help

  Tux includes the `Tux.Help` module to assist you in creating well-structured
  command help message.

  When a command implements the `help/0` callback, if the said command
  is invoked with the `-h` or `--help` flags, it will show something like this:

  ```sh
  ABOUT
    scan - scan strings

  Usage
    strings scan [OPTS] [ARGS]

  Options
    --uppercase, u    Uppercase endpoint name
    --lowercase, u    Lowercase endpoint name

  NOTES
    Here are some additional notes to include
    in the help message.
  ```

  Here's the pipeline used to create the above help message:

      defmodule ScanCmd do
        use Tux.Command

        @impl true
        def about(), do: "Manage systems"

        @impl true
        def main(_, _), do: {:ok, "System managed"}

        @impl true
        def help() do
          Help.new()
          |> Help.about("scan", "scan strings")
          |> Help.usage(["strings scan [OPTS] [ARGS]"])
          |> Help.options([
            {"--uppercase, u", "Uppercase target name"},
            {"--lowercase, u", "Lowercase target name"}
          ])
          |> Help.section("notes", \"\"\"
          Here are some additional notes to include
          in the help message.
          \"\"\")
          |> Help.ok()
        end
      end

  ### 7. Internals

  For quick reference, here's an overview of the most important modules
  of the tux library:

    * `Tux.Alert`      - module for displaying errors (stylized)
    * `Tux.Command`    - command module behaviour
    * `Tux.Config`     - functions for reading and writing text based config files.
    * `Tux.Dispatcher` - macros for command creation and dispatch
    * `Tux.Env`        - a struct to encode preload result and other info
    * `Tux.Error`      - functions user friendly errors construction.
    * `Tux.Exec`       - execute a command module
    * `Tux.Help`       - functions for creating help messages.
    * `Tux.Init`       - construct env prior to command execution
    * `Tux.Prompt`     - functions for prompting and type conversion.
    * `Tux.Result`     - the type returned by commands.
    * `Tux.Show`       - functions for user-friendly output.

  ---

  **More Examples** – A series of runnable examples illustrating
  the usage of the tux library can be found in the
  [examples](https://github.com/threatfender/tux/tree/master/examples) folder
  of the source repository.
  """
end
