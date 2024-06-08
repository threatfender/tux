defmodule Tux.Env do
  @moduledoc """
  The environment struct contains the information required by a
  dispatcher to execute the logic associated with a given CLI command,
  while also being the first argument to be passed to a command module's
  `Tux.Command.main` callback.

  ### Struct Fields

    * `:raw` - the list of all escript args as typed by the user
    * `:cmd` - the command name invoked by the end user which matched
      against dispatcher's registered command names.
      (Note that inside a dispatcher, command registration can be achieved
      using multiple variants: a keyword, a list of keywords, a prefix. – See
      `Tux.Dispatcher.cmd/2` for more details).
    * `:mod` - the command module associated with the given command name.
    * `:fun` - the command module callback to execute – .e.g. `:main` or `:help`.
      This appropriate function is computed based on the given CLI arguments.
      For example, when a `-h` or `--help` flag was provided, the dispatcher will
      invoke the command module's `:help` callback, otherwise the `:main`.
    * `:arg` - the CLI arguments (minus the command name) to pass to the command module
      for command execution.
    * `:dev` - the IO device where output will be written. (See `Tux.Show`).
    * `:pre` - the map with the results from all registered preloads
    * `:dsp` - the context/parent dispatcher module.
    * `:new` - the boolean flag to add newlines to shown success results.
    * `:ext` - the `System` function to invoke when stopping the VM runtime.
      The accepted values are `:halt` or `:stop`.
  """

  @typedoc """
  Received arguments from the command line (includes the command string)
  """
  @type raw :: [String.t()]

  @typedoc """
  The name of the requested command captured from the CLI args
  """
  @type cmd :: :empty | String.t()

  @typedoc """
  The module found for the command
  """
  @type mod :: :not_found | module()

  @typedoc """
  The function name of the command module to execute
  """
  @type mfn :: :main | :help

  @typedoc """
  Final arguments to pass to the command module's main function
  """
  @type arg :: [String.t()]

  @typedoc """
  Device where to print the result
  """
  @type dev :: atom() | pid()

  @typedoc """
  The module within which the `env.mod` was registered.
  """
  @type dsp :: module()

  @typedoc """
  Preloads executed prior to command main execution
  """
  @type pre :: %{atom() => any()}

  @typedoc """
  A flag which notes if a new line should be written to
  env device when a {:ok, result} is returned
  """
  @type new :: boolean()

  @typedoc """
  The function to use on the module `System`, when terminating
  command execution.
  """
  @type ext :: :halt | :stop

  @typedoc """
  The environment contains all the facts necessary for command execution
  including any warmup artifacts.
  """
  @type t :: %__MODULE__{
          # Captured arguments from the command line
          raw: raw,

          # Input command name
          cmd: cmd,

          # The module responsible for command execution
          mod: mod,

          # The function name of the command module to execute
          fun: mfn,

          # Preloads
          pre: pre,

          # Final args to pass to the command module
          arg: arg,

          # Output device
          dev: dev,

          # Where was this module registered in
          dsp: dsp,

          # New line with non-empty success results
          new: new,

          # The function to use to terminate the program
          ext: ext
        }

  defstruct [:raw, :cmd, :mod, :fun, :arg, :dev, :dsp, :pre, :new, :ext]

  @doc """
  Return a new empty environment struct.
  """
  def new(), do: struct!(__MODULE__)

  @typedoc """
  An environment's accepted field name.
  """
  @type field :: :raw | :cmd | :mod | :fun | :pre | :arg | :dev | :dsp | :new | :ext

  @typedoc """
  An environment's accepted field value.
  """
  @type value :: raw | cmd | mod | mfn | pre | arg | dev | dsp | new | ext

  @doc """
  Set or update a struct's field, while also performing some type checks
  to validate if a given value conforms to the struct's specs.
  """
  @spec add(t(), field, value) :: t()
  def add(env, :raw, raw) when is_list(raw),
    do: %{env | raw: raw}

  def add(env, :cmd, cmd) when is_binary(cmd),
    do: %{env | cmd: cmd}

  def add(env, :mod, mod) when is_atom(mod),
    do: %{env | mod: mod}

  def add(env, :fun, fun) when is_atom(fun),
    do: %{env | fun: fun}

  def add(env, :pre, pre) when is_map(pre),
    do: %{env | pre: pre}

  def add(env, :arg, arg) when is_list(arg),
    do: %{env | arg: arg}

  def add(env, :dev, dev) when is_atom(dev) or is_pid(dev),
    do: %{env | dev: dev}

  def add(env, :dsp, dsp) when is_atom(dsp),
    do: %{env | dsp: dsp}

  def add(env, :new, new) when is_boolean(new),
    do: %{env | new: new}

  def add(env, :ext, ext) when ext in [:halt, :stop],
    do: %{env | ext: ext}
end
