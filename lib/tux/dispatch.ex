defmodule Tux.Dispatcher do
  @moduledoc """
  Dispatchers are modules which control program flow by directing the command execution
  to the appropriate command module in response to a given command/sub-command
  invoked by the CLI's end user.

  ## Creating Dispatchers

  New dispatchers are created by invoking `use Tux.Dispatcher` in your own
  modules, and then employing the various macros injected to register
  `Tux.Command` modules for their respective command names.

  ### Example

      defmodule MyProgram do
        use Tux.Dispatcher, opts

        cmd "ping", PingCmd, preloads: [:auth]
        cmd "pong", PongCmd, preloads: [:auth, :log]

        cmd "group", AnotherDispatcherWithSubcommands

        cmd ~w"h hello", HelloCmd
        cmd ~p".a", CommandTriggeredByDotAPrefix

        # Alternatively
        pre [:config, :auth, :log] do
          cmd "ping", PingCmd
          cmd "pong", PongCmd
        end
      end

  ## Dispatcher Options

  A dispatcher's behaviour can be customized by providing a list of options:

      use Tux.Dispatcher, [... rescue: true, colors: false, ...]

  Available dispatcher options are:

    * `:rescue` - a boolean flag to rescue from command exceptions (default is `false`)
    * `:device` - the `t:IO.device/0` to write the command output to
      (default is `:stdio`)
    * `:newlines` - a boolean flag to append new lines to outputs for nicer
      outputs (default is `true`)
    * `:colors` - a boolean flag to enable/disable colored outputs (default is `true`)
    * `:preloads` - a list of functions to execute prior to executing a command module
      (default is `[]`). The results of these preloads will be accessible
      in the command module's `c:Tux.Command.main/2` callback as `env.pre.*`,
      where `*` is the function name or the key (if one was specified).
      – See [Dispatcher Preloads](#module-dispatcher-preloads) below for more details.
    * `:exitwith` - the name of the function of the `System` module to invoke
      in order to terminate the VM when a command returns an error result.
      Accepted values are `:halt` and `:stop`. (default is `:halt`).
      See [Erlang VM Exits](#module-erlang-vm-exits) below for more details.

  ### Erlang VM Exits

  When a command module returns an error, tux will terminate your program with
  a non-zero exit code, so the failure can be reflected in the shell status code.

  By default, in the case of errors tux terminates the program with `System.halt/1`
  (the default escript behaviour) because it is faster and we want responsive CLIs.
  However, if for whatever reason you need your system to gracefully come to a stop
  (say you have processes which need to perform come cleanup), you can change
  this behaviour by specifying `exitwith: :stop` in the dispatcher's options.

  ## Dispatcher Preloads

  In many cases, prior to the actual execution of a command, some piece of data
  is needed (e.g. data read from a config file, etc). And since this pattern could
  recur across many commands of a given CLI, tux introduces the concept of
  **preloads**.

  Preloads are functions to be executed sequentially, prior to the invocation of
  a command module, and whose results will be collected under the `.pre` key of the
  `Tux.Env` struct passed to the command module's `c:Tux.Command.main/2` callback.

  Preloads can be declared at both the *dispatcher definition* and
  *command registration* levels, and are executed sequentially in the order in which
  they were defined in the tux command hierarchy. Thus, the can be declared:

    * At dispatcher level – using the `:preloads` dispatcher option. *(executed 1st)*
    * At command registration level - using the `pre/2` *(2nd)* and `cmd/3` *(3rd)* macros.

  ### Preloads Format

  Preloads can specified using any of the following formats (Note that `key`, `fun`,
  and `mod` are atoms) and are found under the `Tux.Env`s `.pre` key:

  | Preload Format           | Example                       | Preload Result  |
  |:-------------------------|:------------------------------|:----------------|
  | `fun`                    | `:config`                     | `env.pre.<fun>` |
  | `{key, fun}`             | `{c!: :config}`               | `env.pre.<key>` |
  | `{mod, fun, args}`       | `{MyPre, :config, []}`        | `env.pre.<fun>` |
  | `{key, {mod, fun, args}}`| `{:mc!, {MyPre, :config, []}}`| `env.pre.<key>` |

  When a preload is specified using a function name, that function must exist
  in the dispatcher where that preload is being specified.

  ### Preloads Examples

  Here's a list of preloads specified using multiple formats at once:

      defmodule MyPreloads do
        def config(env), do: "My config file"
        def config(env, :upcase), do: "MY CONFIG FILE"
      end

      defmodule MyDispatcher do
        use Tux.Dispatcher

        cmd "show", MyCmd, preloads: [:conf,
                                      c1: :conf,
                                      c2: {MyPreloads, :config, []},
                                      c3: {MyPreloads, :config, [:upcase]}
                                     ]

        def conf(env), do: "My config file"
      end

      defmodule MyCmd do
        use Tux.Command

        def main(env, _) do
          IO.inspect(env.pre.conf)
          IO.inspect(env.pre.c1)
          IO.inspect(env.pre.c2)
          IO.inspect(env.pre.c3)
        end
      end

  And here's an example with preloads specified at multiple levels
  in the tux command hierarchy:

      defmodule MyDispatcher do
        use Tux.Dispatcher, preloads: [:auth, one: :inc]

        def auth(_env), do: true
        def inc(_env), do: 1
        def inc(env, prev), do: env.pre[prev] + 1

        defmodule CollectCmd do
          use Tux.Command

          @impl true
          def main(env, _args) do
            true = env.pre.auth
            {:ok, "Summing all preloads should yield three: \#{env.pre.three}"}
          end
        end

        pre [two: {MyDispatcher, :inc, [:one]}] do
          cmd "collect", CollectCmd, preloads: [three: {MyDispatcher, :inc, [:two]}]
        end
      end

  ## Dispatcher Internals

  A dispatcher is broken up internally into various stages:

    * `Tux.Init` - for command preloads execution and `Tux.Env` initialization
    * `Tux.Exec` - for command execution
    * `Tux.Show` - for command output display
    * `Tux.Exit` - for command exits & stopping the VM
    * `Tux.Help` - for dispatcher help message generation
  """

  @typedoc """
  An output `t:IO.device/0` such as `:stdio` or another process.
  """
  @type device :: IO.device()

  @typedoc """
  Preloads are list of functions to execute prior to a command.

  They can be specified in the following formats:

    * as a FUNCTION name
    * as the {KEY, FUNCTION name} tuple
    * as the {MODULE, FUNCTION name, Args} tuple
    * as the {KEY, {MODULE, FUNCTION name, Args}} tuple

  """
  @type preloads :: [
          atom()
          | {atom(), atom()}
          | {module(), atom(), list()}
          | {atom(), {module(), atom(), list()}}
        ]

  @typedoc """
  The struct which encodes the dispatcher and its options.
  """
  @type t :: %__MODULE__{
          # Command rescue flag. This attribute is retrieved internally
          # via the `rescue?/0` function
          rescue: boolean(),

          # Command output device. This attribute is retrieved internally
          # via the `device/0` function
          device: device(),

          # Whether to print newline on non-empty content returned
          # with the {:ok, tuple} ...
          newlines: boolean(),

          # A flag whether to use colors for outputs
          colors: boolean(),

          # A list of preload functions
          preloads: preloads(),

          # `System` function to use when ending the program
          exitwith: :halt | :quit
        }

  defstruct ~w(rescue device newlines colors preloads exitwith)a

  @doc """
  Return a new dispatcher struct, and override its default values
  with those given in the `args` parameter:

      iex> Tux.Dispatcher.new(rescue: true, colors: false)
      %Tux.Dispatcher{colors: false, device: :stdio, exitwith: :halt,
                      newlines: true, preloads: [], rescue: true}

  """
  @spec new(Keyword.t()) :: t()
  def new(args) when is_list(args) do
    defaults = [
      rescue: false,
      device: :stdio,
      newlines: true,
      colors: true,
      preloads: [],
      exitwith: :halt
    ]

    struct!(__MODULE__, Keyword.merge(defaults, args))
  end

  @typedoc """
  Command name used for command module registration
  """
  @type cmd_name :: String.t()

  @typedoc """
  Command module associated with a command name
  """
  @type cmd_module :: module()

  @typedoc """
  Command registration options.
  """
  @type cmd_opts :: [preloads: preloads()]

  @doc """
  Dispatch command execution to the appropriate command module registered
  for a given command name extracted from the command line arguments.

  Using its `main/1` function, a dispatcher can also serve as the main module
  of an escript.
  """
  @callback main(args :: [String.t()]) :: :ok

  @doc """
  Return an `{:ok, _}` tuple which contains a string or the `Tux.Help` struct, and
  whose purpose is to encode the dispatcher's help message.

  This callback is injected automatically when `use Tux.Dispatcher`
  is invoked, however it can also be overwritten.
  """
  @callback help() :: {:ok, Tux.Help.t()}

  @doc """
  Register a command module for a given command name in the current dispatcher.

  This macro is imported automatically whenever you `use Tux.Dispacher`.

  ## Options

    * `:preloads` -  a list of functions to execute prior to command execution.
      Preload results will be accessible in the command module's `main/2` callback
      as `env.pre.*`. – See the [Dispatcher Preloads](#module-dispatcher-preloads)
      section for preload specification format.

  ## Example

      defmodule Program do
        use Tux.Dispatcher

        cmd "ping", Ping
        cmd "cat", Cat, preloads: [:auth, :log]

        defmodule Ping do
          def main(args), do: ...
        end

        defmodule Cat do
          def main(args), do: ...
        end
      end

  Do note that dispatchers can be infinitely nested.
  For example, this is valid:

      defmodule Program.Design do
        use Tux.Dispatcher
        cmd "intro", Program.Design.Intro
        cmd "advanced", Program.Design.Advanced
      end

      defmodule Program.Engineering do
        use Tux.Dispatcher
        cmd "intro", Program.Engineering.Intro
        cmd "advanced", Program.Engineering.Advanced
      end

      defmodule Program do
        use Tux.Dispatcher
        cmd "design", Program.Design
        cmd "engineering", Program.Engineering
      end


  ## Command Names

  In tux you can define command names using:

    * a single keyword, e.g. `ping`
    * multiple keywords (the command will be triggered by any of the given keywords),
      e.g. `~w(ping p)`
    * a prefix (the command triggered by any string sequence which begins with the
      given prefix) `~p(pi)`

  ### 1. Command Names using Single Keywords

  As illustrated above a command can be defined by an exact word:

      cmd "foo", FooCommandModule

  Invocation:

  ```
  $ myprog foo
  ```

  ### 2. Command Names using Multiple Keywords

  You can also register multiple names for a command at once,
  useful when you need multiple names (long + short) for a command.

      cmd ~w(foo f), FooCommandModule

  Now you can invoke both the `foo` and `f` commands, which point
  to the same command module:

  ```
  $ myprog foo
  $ myprog f
  ```

  ### 3. Command Names using a Prefix Keyword

  In addition to creating commands identified by keywords, tux allows you to
  define commands using prefixes, meaning a command module will be invoked
  in response to any given string sequence which begins with the prefix:

      cmd ~p"fo", FooCommandModule

  The command above will be triggered by any sequence of characters that
  begin with `foo...`. For example, these are all equivalent command invocations:

  ```
  $ myprog fo
  $ myprog foo
  $ myprog foa
  $ myprog foab
  $ myprog foabc
  ```

  Do note that you can extract the full keyword which triggered the command
  from the `env.cmd` in your command module's `main` function.

  """
  @spec cmd(cmd_name(), cmd_module(), cmd_opts()) :: Macro.t()
  defmacro cmd(name, module, opts \\ []) do
    # NOTE: This section will be execute before `__before_compile__`.
    quote bind_quoted: [name: name, module: module, opts: opts] do
      if module == __MODULE__ do
        msg =
          "The module `#{Macro.to_string(module)}` registered for the `#{name}` command" <>
            "\ncannot coincide the the dispatcher module."

        # "Cannot register command `#{name}` with the module `#{Macro.to_string(module)}`" <>
        # "\nbecause the latter is one and the same with the dispatch module."

        raise %CompileError{
          description: """

          #{Tux.Colors.red(msg)}

          #{Tux.Colors.bold("DO NOT DO THIS:")}
            defmodule #{Tux.Colors.blue("#{Macro.to_string(module)}")} do
              use Tux.Dispatcher
              cmd "#{name}", #{Tux.Colors.red("#{Macro.to_string(module)}")}
            end

          #{Tux.Colors.bold("DO THIS INSTEAD:")}
            defmodule #{Tux.Colors.blue("#{Macro.to_string(module)}")} do
              use Tux.Dispatcher
              cmd "#{name}", #{Tux.Colors.green("SomeOtherModule")}
            end
          """
        }
      else
        # Register Command
        case name do
          cmd when is_binary(cmd) ->
            @cmds {{:exact, cmd}, module, opts}

          cmds when is_list(cmds) ->
            Enum.each(cmds, fn cmd ->
              @cmds {{:exact, cmd}, module, opts}
            end)

          {:prefix, cmd} when is_binary(cmd) ->
            @cmds {{:prefix, cmd}, module, opts}
        end
      end
    end
  end

  @doc """
  Register a series of commands with common preloads, thus you can replace
  the following block:
  ```
  cmd "hello", HelloCmd, preload: [:auth, :log]
  cmd "bye", ByeCmd, preload: [:auth, :log]
  ```
  with a more simplified form:

  ```
  pre [:auth, :log] do
    cmd "hello", HelloCmd
    cmd "bye", ByeCmd
  end
  ```
  """
  @spec pre(preloads, do: Macro.t()) :: Macro.t()
  defmacro pre(preloads, do: {:__block__, context, cmds}) do
    {:__block__, context, update_preloads(preloads, cmds)}
  end

  defmacro pre(preloads, do: {:cmd, context, _} = line) do
    [{:cmd, _, updated}] = update_preloads(preloads, [line])
    {:cmd, context, updated}
  end

  # Macro helper to update the preloads for each cmd in `cmds`
  # with those supplied in the `preloads`
  defp update_preloads(preloads, cmds) do
    Enum.reduce(cmds, [], fn cmd, acc ->
      case cmd do
        # Merge given `preload` above with the current preloads
        # defined for the command
        {:cmd, ctx1, [name, ctx2, opts]} ->
          existing_preloads = Keyword.get(opts, :preloads, [])
          new_opts = Keyword.put(opts, :preloads, preloads ++ existing_preloads)
          acc ++ [{:cmd, ctx1, [name, ctx2, new_opts]}]

        # Insert the `preloads` given above as command options
        {:cmd, ctx1, [name, ctx2]} ->
          opts = [preloads: preloads]
          acc ++ [{:cmd, ctx1, [name, ctx2, opts]}]
      end
    end)
  end

  @doc """
  A sigil which can be used to register a command module with
  a given prefix instead of a complete name.

  This is useful when you want to reduce typing and trigger a given command
  by a certain prefix and not a full name.

  ## Example

      defmodule Program do
        use Tux.Dispatcher

        cmd ~p".", LetterCmd
      end

  The complete typed command will then be available in the`Tux.Env` given
  to the command module:

      defmodule LetterCmd do
        use Tux.Command

        @impl true
        def main(env, _args) do
          case String.split(env.cmd, ".", parts: 2) do
            ["", "a"] -> {:ok, "You typed A"}
            ["", "b"] -> {:ok, "You typed B"}
            _ -> {:error, "Invalid letter"}
          end
        end
      end

  ```sh
  $ program .a --some-flag
  You typed A

  $ program .b --some-flag
  You typed B
  ```
  """
  def sigil_p(cmd, []),
    do: {:prefix, cmd}

  @doc """
  Inject the utility functions whose role is to retrieve
  the dispatcher options at runtime (used internally).
  """
  defmacro __before_compile__(_env) do
    quote do
      @doc """
      Return the list of registered commands:  [{name, module, opts}]
      """
      def cmds(), do: Enum.reverse(@cmds)

      @doc """
      A flag to rescue from failure during command execution
      """
      def rescue?(), do: @__dispatcher__.rescue

      @doc """
      Return the command device where to write the result
      """
      def device(), do: @__dispatcher__.device

      @doc """
      Return the flag which informs the show function
      to print a newline along with the non-empty {:ok, content}
      command result.
      """
      def newlines?(), do: @__dispatcher__.newlines

      @doc """
      A flag whether to use colors when generating the help
      """
      def colors?(), do: @__dispatcher__.colors

      @doc """
      The list dispatcher's preloads as passed to `__using__/1`
      """
      def preloads(), do: @__dispatcher__.preloads

      @doc """
      Return the dispatcher `exitwith` field.
      """
      def exitwith(), do: @__dispatcher__.exitwith

      @doc """
      Return the dispatcher struct
      """
      def __dispatcher__(), do: @__dispatcher__
    end
  end

  @doc """
  Inject the core dispatcher functionality for registration and dispatch
  of command modules.

  ## Use Options:

    * `:rescue` (boolean) - when set to true, if will rescue from command exceptions
      and when false it will show the exception's stacktrace (default is false).
    * `:device` (io device) - the device where to send the command results
      (default is :stdio).
    * `:newlines` (boolean) - whether to print the newline character with successful,
      non-empty command results (defaults is true).

  ## Use Examples:

      defmodule GeneralDispatcher do
        use Tux.Dispatcher
        # ...
      end

      defmodule CatchExceptionsDispatcher do
        use Tux.Dispatcher, rescue: true, colors: false
        # ...
      end
  """
  defmacro __using__(opts \\ []) when is_list(opts) do
    quote bind_quoted: [opts: opts] do
      @__dispatcher__ Tux.Dispatcher.new(opts)

      # Storage location for command modules. This attribute is a list
      # of items in the form `{{:exact|:prefix, cmd}, module, opts}`
      # and is retrieved internally using the `cmds/0` function.
      Module.register_attribute(__MODULE__, :cmds, accumulate: true)

      @behaviour Tux.Init
      @behaviour Tux.Exec
      @behaviour Tux.Show
      @behaviour Tux.Exit
      @behaviour Tux.Help

      use Tux.Init, overridable: true
      use Tux.Exec, overridable: true
      use Tux.Show, overridable: true
      use Tux.Exit, overridable: true
      use Tux.Help, overridable: true

      import Tux.Dispatcher, only: [cmd: 2, cmd: 3, pre: 2, sigil_p: 2]

      @typedoc """
      Command line args
      """
      @type args :: [String.t()]

      @typedoc """
      Preload results
      """
      @type pre :: map()

      @doc """
      The main function which can be delegated to from the escript
      main module.

      This function simply calls `dispatch/2` with empty preload results.
      """
      @spec main(args) :: :ok
      def main(args), do: dispatch(%{}, args)

      @doc """
      Select a command module based on the invoked command (first arg)
      build the environment, execute preloads, then execute the command module's
      main function.
      """
      @spec dispatch(pre, args) :: :ok
      def dispatch(pre, args) do
        pre
        |> make_cmd_context(args)
        |> exec_cmd_module()
        |> show_cmd_result()
      end

      defp make_cmd_context(pre, args) do
        if "--debug" in args do
          args = Enum.reject(args, fn arg -> arg == "--debug" end)
          {:debug, init(pre, args)}
        else
          {:normal, init(pre, args)}
        end
      end

      defp exec_cmd_module(context) do
        case context do
          {_, %Tux.Env{mod: :not_found} = env} ->
            result = {:error, Tux.Errors.CommandNotFoundError.new(name: env.cmd)}
            {env, result}

          {:debug, env} ->
            {env, exec(env, rescue: false)}

          {:normal, env} ->
            {env, exec(env, rescue: rescue?())}
        end
      end

      defp show_cmd_result({env, result}) do
        case env.mod do
          # Command not found, so we use the dispatcher module to show the result
          :not_found ->
            apply(__MODULE__, :show, [env, result])
            apply(__MODULE__, :exit, [env, result])

          module ->
            apply(module, :show, [env, result])

            # Only exit using the command module's exit callback
            if role?(module) == :command_module,
              do: apply(module, :exit, [env, result]),
              else: :ok
        end
      end

      # Return the role of a module
      defp role?(module) do
        case Keyword.get_values(module.__info__(:functions), :__dispatcher__) do
          [0] -> :dispatcher_module
          [] -> :command_module
        end
      end

      @before_compile Tux.Dispatcher
      @after_compile Tux.Dispatcher

      @doc """
      A dispatcher can also be a command module, so here we implement its
      `main/2` function, which will simply pass down its preload results
      and perform the dispatch operation down to the next command module.
      """
      def main(env, args), do: dispatch(env.pre, args)
    end
  end

  @doc """
  Perform sanity checks for a dispatcher's registered command names
  and associated command modules.
  """
  def __after_compile__(macro_env, _bytecode) do
    check_command_modules(macro_env)
    check_command_conflicts(macro_env)
  end

  # Ensure all command modules registered inside the
  # dispatcher implement the main function.
  defp check_command_modules(macro_env) do
    require Logger

    log_missing_module = fn module, reason ->
      Logger.warning(
        "#{Macro.to_string(module)} is registered as a command module, " <>
          "but hasn't been compiled, reason = #{reason}."
      )
    end

    log_missing_main = fn module ->
      Logger.warning(
        "#{Macro.to_string(module)} is registered as a command module, " <>
          "but hasn't implemented a `main` function."
      )
    end

    Enum.map(
      macro_env.module.cmds(),
      fn {_cmd_def, cmd_module, _cmd_module_opts} ->
        case Code.ensure_compiled(cmd_module) do
          {:module, compiled} ->
            compiled.__info__(:functions)
            |> Keyword.get_values(:main)
            |> case do
              [] ->
                log_missing_main.(compiled)

              _ ->
                :noop
            end

          {:error, reason} ->
            log_missing_module.(cmd_module, reason)
        end
      end
    )
  end

  # Check if registered command names conflict
  defp check_command_conflicts(env) do
    names = env.module.cmds() |> Enum.map(fn {{_, name}, _, _} -> name end)
    commands = env.module.cmds()

    for name <- names do
      case Tux.Locator.locate_cmd_module(commands, name) do
        {:error, :cmd_conflict} ->
          raise %CompileError{
            description: """


              #{Tux.Colors.red("Conflicting Command Definitions")}
              │
              │ * Command #{Tux.Colors.red(name)} conflicts with an existing command.
              │ * Are you using prefixed commands? Double check for conflicts!
              │
              └─ Location: #{Tux.Colors.red(Macro.to_string(env.module))} module
                 File: #{Tux.Colors.red(Path.basename(env.file))}
            """
          }

        _ ->
          :noop
      end
    end
  end
end
