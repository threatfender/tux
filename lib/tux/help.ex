defmodule Tux.Help do
  @moduledoc """
  Create beautiful looking, well-structured help messages
  for commands or dispatchers.

  ## Features
    * Elegant layouts
    * Minimal coloring
    * Customizable

  ## Example

  Here's an example of a well structured command help message
  which you can create with tux:

  ```sh
  ABOUT
    mng - command for controlling systems

  USAGE
    tool mng [OPTS] [ARGS]

  OPTIONS
    --upcase, u        Uppercase endpoint name
    --lowercase, l     Lowercase endpoint name

  NOTES
    Here are some additional notes to include
    in the help message.
  ```

  ### Pipelined Help Messages

  The help message above can be created with the following `Tux.Help` pipeline:

      defmodule MngCmd do
        use Tux.Command

        @impl true
        def main(_, _), do: ...

        @impl true
        def help() do
          Help.new()
          |> Help.about("mng", "command for controlling systems")
          |> Help.usage(["tool mng [OPTS] [ARGS]"])
          |> Help.options([
            {"--upcase, u", "Uppercase endpoint name"},
            {"--lowercase, l", "Lowercase endpoint name"},
          ])
          |> Help.section("notes", \"\"\"
          Here are some additional notes to include
          in the help message.
          \"\"\")
          |> Help.ok()
        end
      end

  ### Manual Help Messages

  If you want complete control over your help messages, you can construct
  them manually. Here's the code that would render the above help message:

      defmodule MngCmd do
        use Tux.Command

        @impl true
        def help() do
          \"\"\"
          \#{bold("ABOUT")}
            mng - command for controlling systems
          \#{bold("\\nUSAGE")}
            \#{green("tool mng [OPTS] [ARGS]")}
          \#{bold("\\nOPTIONS")}
            \#{green("--upcase, u")}        Uppercase endpoint name
            \#{green("--lowercase, l")}     Lowercase endpoint name
          \#{bold("\\nNOTES")}
            Here are some additional notes to include
            in the help message.
          end
          \"\"\"
          |> Help.ok()
        end
    end

  """

  @typedoc """
  The help struct
  """
  @type t :: %__MODULE__{
          # When true, it will colorize sections
          color: boolean(),

          # A flag to uppercase section titles
          upcase: boolean(),

          # The colorizer function
          hue: fun(),

          # All section text blocks of the help message
          sections: [any()]
        }

  defstruct ~w(color upcase hue sections)a

  @typedoc "A program binary name"
  @type bin_name :: String.t()

  @typedoc "A program description"
  @type bin_desc :: String.t()

  @typedoc "A command name"
  @type cmd_name :: String.t()

  @typedoc "A command description"
  @type cmd_desc :: String.t()

  @typedoc "A flag name"
  @type flg_name :: String.t()

  @typedoc "A flag description"
  @type flg_desc :: String.t()

  @typedoc "A help message section's title"
  @type sec_title :: String.t()

  @typedoc "Options for section creation"
  @type sec_opts :: [
          # Optional custom section title
          title: String.t()
        ]

  #
  ## HELP BEHAVIOUR
  #

  @doc """
  One line, command description
  """
  @callback about() :: String.t()

  @doc """
  Return a help struct for showing help messages
  """
  @callback help() :: {:ok, __MODULE__.t() | String.t()}

  @optional_callbacks about: 0, help: 0

  #
  ## HELP FUNCTIONS
  #

  import Tux.Colors

  @doc """
  Initialize a new help struct with the given options.

  ## Examples

      iex> Tux.Help.new()
      %Tux.Help{color: true, hue: &Tux.Help.highlight/2, sections: [], upcase: true}

      iex> Tux.Help.new(color: false)
      %Tux.Help{color: false, hue: &Tux.Help.highlight/2, sections: [], upcase: true}

  ## Options

  When constructing a new help struct you can customize its behaviour
  with the following options:

    * `:hue` (fun/2)
      – function for coloring/styling (*default is `Tux.Help.highlight/2`*)
    * `:color` (boolean)
      – flag to colorize help sections (*default is true*)
    * `:upcase` (boolean)
      – flag to uppercase the section titles (*default is true*)

  """
  @spec new(Keyword.t()) :: t()
  def new(opts \\ []) do
    struct!(__MODULE__,
      color: Keyword.get(opts, :color, true),
      hue: Keyword.get(opts, :hue, &__MODULE__.highlight/2),
      upcase: Keyword.get(opts, :upcase, true),
      sections: []
    )
  end

  @doc """
  Default highlight style for certain elements such as
  command names or option/flag names.

  The current implementation will embolden text and
  color it green.
  """
  def highlight(text, enabled \\ true),
    do: _highlight(text, enabled)

  defp _highlight(text, false),
    do: text

  defp _highlight(text, true),
    do: text |> Tux.Colors.bold() |> Tux.Colors.green()

  @doc """
  Build the specification for section creation
  """
  @spec build_specs(sec_title, sec_opts) :: %{color: boolean(), title: String.t()}
  def build_specs(title, opts) do
    defaults = %{title: title}
    Map.merge(defaults, Enum.into(opts, %{}))
  end

  @doc """
  Return the string representation of section head
  """
  @spec head(t(), String.t()) :: String.t()
  def head(help, title) do
    title = if help.upcase, do: String.upcase(title), else: title
    "#{bold(title, help.color)}"
  end

  @doc """
  Append the about section which describes the command.

      iex> Tux.Help.new(color: false)
      ...> |> Tux.Help.about("this is the one line cmd description")
      ...> |> String.Chars.to_string()
      "ABOUT\\n" <>
      "  this is the one line cmd description\\n"
  """
  @spec about(t, bin_desc) :: t()
  def about(help, description) do
    text = String.trim_trailing(description)

    """
    #{head(help, "about")}
      #{text}
    """
    |> (fn section_text -> text(help, section_text) end).()
  end

  @doc """
  Append the about section which describes the command.

  ## Example

  Specifying the command name in the about section

      iex> Tux.Help.new(color: false)
      ...> |> Tux.Help.about("cmd", "this is the one line cmd description")
      ...> |> String.Chars.to_string()
      "ABOUT\\n" <>
      "  cmd - this is the one line cmd description\\n"

  """
  @spec about(t, bin_name, bin_desc) :: t()
  def about(help, name, description) do
    text = String.trim_trailing("#{name} - #{description}")

    """
    #{head(help, "about")}
      #{text}
    """
    |> (fn section_text -> text(help, section_text) end).()
  end

  @doc """
  Append the usage section, where a very short, general structure of the command
  is presented.

  ## Examples

  #### – Populate usage section via plain text

      iex> Tux.Help.new(color: false)
      ...> |> Tux.Help.usage("cmd [OPTS] [ARGS]")
      ...> |> String.Chars.to_string()
      "USAGE\\n" <>
      "  cmd [OPTS] [ARGS]\\n"


  #### – Populate usage section using a list of commands:

      iex> Tux.Help.new(color: false)
      ...> |> Tux.Help.usage(["cmd1", "cmd2", "cmd3"])
      ...> |> String.Chars.to_string()
      "USAGE\\n"<>
      "  cmd1\\n" <>
      "  cmd2\\n" <>
      "  cmd3\\n"

  #### – Using a list of commands with one line descriptions:

      iex> Tux.Help.new(color: false)
      ...> |> Tux.Help.usage([
      ...> {"cmd1", "cmd 1 description"},
      ...> {"cmd2", "cmd 2 description"},
      ...> ])
      ...> |> String.Chars.to_string()
      "USAGE\\n" <>
      "  cmd1    cmd 1 description\\n" <>
      "  cmd2    cmd 2 description\\n"


  ## Options for `usage/3`:

    * `:title` (string) - overwrite the default usage title with a custom one
    * `:hued` (boolean) - a flag to colorize commands (default is true)

  """
  @spec usage(t, cmd_name | [cmd_name | {cmd_name, cmd_desc}], sec_opts) :: t()
  def usage(help, cmd_or_cmds, opts \\ []) do
    specs = build_specs("usage", opts)

    # A flag whether to apply styling for usage & other sections
    hued? = help.color && Keyword.get(opts, :hued, true)

    cmd_or_cmds =
      case cmd_or_cmds do
        value when is_binary(value) ->
          [value]

        value when is_list(value) ->
          value

        value ->
          raise ArgumentError,
            message: """
            #{blue(inspect(value))} #{red("<- bad type")}. Supported types: string, list.
            """
      end

    ("#{head(help, specs.title)}\n" <>
       (cmd_or_cmds
        |> Enum.map(fn
          {cmd, desc} -> {help.hue.(cmd, hued?), desc}
          cmd -> {help.hue.(cmd, hued?), ""}
        end)
        |> align_pairs(2, 4)
        |> Enum.map(fn {first, second} -> String.trim_trailing("#{first}#{second}") end)
        |> Enum.join("\n")) <> "\n")
    |> (fn section_text -> text(help, section_text) end).()
  end

  @doc """
  Define the options section

  ## Example

      iex> alias Tux.Help
      ...> Help.new(color: false)
      ...> |> Help.options([
      ...> {"--flag1", "flag1 description"},
      ...> {"--flag2", "flag2 description"},
      ...> {"--flag3", "flag3 description"},
      ...> ])
      ...> |> to_string()
      "OPTIONS\\n" <>
      "  --flag1    flag1 description\\n" <>
      "  --flag2    flag2 description\\n" <>
      "  --flag3    flag3 description\\n"

  """
  @spec options(t(), [{flg_name, flg_desc}], sec_opts) :: t()
  def options(help, options, opts \\ []) when is_list(options) do
    specs = build_specs("options", opts)

    text =
      options
      |> Enum.map(fn {name, desc} -> {help.hue.(name, help.color), desc} end)
      |> align_pairs(2, 4)
      |> Enum.map(fn {first, second} -> String.trim_trailing("#{first}#{second}") end)
      |> Enum.join("\n")

    """
    #{head(help, specs.title)}
    #{text}
    """
    |> (fn section_text -> text(help, section_text) end).()
  end

  @doc """
  Append the commands section to the help struct.

  ## Example

      iex> alias Tux.Help
      ...> Help.new(color: false)
      ...> |> Help.commands([
      ...> {"start", "Start something"},
      ...> {"stop", "Stop something"},
      ...> ])
      ...> |> to_string()
      "COMMANDS\\n" <>
      "  start    Start something\\n" <>
      "  stop     Stop something\\n"

  """
  @spec commands(t(), [{cmd_name, cmd_desc}], sec_opts) :: t()
  def commands(help, options, opts \\ []) when is_list(options) do
    opts = Keyword.merge([title: "commands"], opts)
    options(help, options, opts)
  end

  @doc """
  Create a custom help section with a given title and body.

  ## Example

      iex> alias Tux.Help
      ...> Help.new(color: false)
      ...> |> Help.section("notes", "some custom section" <> "\\nand more")
      ...> |> to_string()
      "NOTES\\n" <>
      "  some custom section\\n" <>
      "  and more"

  """
  @spec section(t(), String.t(), String.t(), Keyword.t()) :: t()
  def section(help, title, body, opts \\ []) do
    specs = build_specs(title, opts)

    aligned_text =
      body
      |> String.split("\n")
      |> Enum.map(fn line -> "  #{String.trim(line)}" end)
      |> Enum.join("\n")

    ("#{head(help, specs.title)}\n" <> aligned_text)
    |> (fn section_text -> text(help, section_text) end).()
  end

  @doc """
  Return the help struct wrapped in a `{:ok, ..}` tuple.

      iex> Tux.Help.new(color: false)
      ...> |> Tux.Help.about("this is my command")
      ...> |> String.Chars.to_string()
      ...> |> Tux.Help.ok()
      {:ok, "ABOUT\\n" <>
      "  this is my command\\n"}

  """
  @spec ok(t()) :: {:ok, t()}
  def ok(help) do
    {:ok, help}
  end

  @doc """
  Append a new block of text as a new section.
  """
  @spec text(t(), String.t()) :: t()
  def text(help, section) do
    %{help | sections: help.sections ++ [section]}
  end

  @doc """
  Append a title styled to the help sections.
  """
  @spec title(t(), String.t()) :: t()
  def title(help, string) do
    %{help | sections: help.sections ++ [bold(string, help.color)]}
  end

  @doc """
  Add one or more newlines.
  """
  @spec newline(t(), pos_integer()) :: t()
  def newline(help, count \\ 1) when count > 0 do
    Enum.reduce(1..count, help, fn _, acc ->
      %{acc | sections: acc.sections ++ [""]}
    end)
  end

  def has_module?(cmds, module) do
    cmds
    |> Enum.filter(fn {mod, _} -> mod == module end)
    |> case do
      [] -> false
      [_] -> true
    end
  end

  def add_cmd(cmds, cmd, with: module) do
    cmds ++ [{module, [cmd]}]
  end

  def add_cmd(cmds, cmd, for: module) do
    Enum.reduce(cmds, [], fn {mod, cmds}, acc ->
      if mod == module do
        acc ++ [{mod, cmds ++ [cmd]}]
      else
        acc ++ [{mod, cmds}]
      end
    end)
  end

  @doc """
  This is used internally by the `Tux.Dispatcher` and will inject the `help/0`
  dispatcher callback for returning the help message.
  """
  defmacro __using__(opts) do
    quote do
      alias Tux.Help

      defmacrop gen_about_section(help, dispatcher) do
        quote bind_quoted: [help: help, dispatcher: dispatcher] do
          if Kernel.function_exported?(dispatcher, :about, 0) do
            Help.about(help, dispatcher.about())
          else
            help
          end
        end
      end

      defmacrop gen_commands_section(help, dispatcher) do
        quote bind_quoted: [help: help, dispatcher: dispatcher] do
          cmds_and_descriptions =
            dispatcher.cmds()
            |> Enum.map(fn {cmd, mod, _} ->
              case cmd do
                {:exact, name} -> {name, mod}
                {:prefix, prefix} -> {"#{prefix}[...]", mod}
              end
            end)
            |> Enum.reduce([], fn {cmd, module}, acc ->
              if Help.has_module?(acc, module),
                do: Help.add_cmd(acc, cmd, for: module),
                else: Help.add_cmd(acc, cmd, with: module)
            end)
            |> Enum.map(fn {module, cmds} ->
              cmds
              |> (fn
                    # Single command
                    [c] ->
                      {module, c}

                    # Sort command names by length (shortcuts at the end)
                    cs when is_list(cs) ->
                      {module,
                       cs
                       |> Enum.sort_by(&String.length(&1), :desc)
                       |> Enum.join(", ")}
                  end).()
            end)
            |> Enum.map(fn {module, cmds} ->
              {:module, _} = Code.ensure_compiled(module)

              if Kernel.function_exported?(module, :about, 0) do
                {cmds, module.about()}
              else
                {cmds, ""}
              end
            end)

          case cmds_and_descriptions do
            [] -> help
            _ -> Help.commands(help, cmds_and_descriptions)
          end
        end
      end

      defp gen_help(dispatcher) do
        Help.new(color: dispatcher.colors?())
        |> gen_about_section(dispatcher)
        |> gen_commands_section(dispatcher)
      end

      @doc """
      Return a default, minimal, auto-generated help message
      for the current dispatcher.
      """
      @impl true
      @spec help() :: {:ok, Tux.Help.t() | String.t()}
      def help(), do: {:ok, gen_help(__MODULE__)}

      if Keyword.get(unquote(opts), :overridable) do
        defoverridable help: 0
      end
    end
  end

  @doc """
  A utility function to align a collection of pair items.

  ## Example

      iex> Tux.Help.align_pairs([
      ...>   {"a", "some description"},
      ...>   {"aaa", "some description"},
      ...>   {"aaaaa", "some description"},
      ...> ], 0, 4)
      [{"a        ", "some description"},
       {"aaa      ", "some description"},
       {"aaaaa    ", "some description"}]

      iex> Tux.Help.align_pairs([
      ...>   {"a", "some description"},
      ...>   {"aaa", "some description"},
      ...>   {"aaaaa", "some description"},
      ...> ], 2, 1)
      [{"  a     ", "some description"},
       {"  aaa   ", "some description"},
       {"  aaaaa ", "some description"}]

  """
  def align_pairs(pairs, left_pad, inter_pad)
      when is_integer(left_pad) and is_integer(inter_pad) do
    max_len =
      pairs
      |> Enum.map(fn {first, _} -> first end)
      |> Enum.map(&String.length(&1))
      |> Enum.max()

    Enum.map(pairs, fn {first, second} ->
      {String.duplicate("\s", left_pad) <>
         first <>
         String.duplicate("\s", max_len - String.length(first)) <>
         String.duplicate("\s", inter_pad), second}
    end)
  end
end

defimpl String.Chars, for: Tux.Help do
  @doc """
  Return the string representation of a help struct, by
  joining all of its sections together.
  """
  def to_string(help) do
    Enum.join(help.sections, "\n")
  end
end
