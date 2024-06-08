defprotocol Tux.Alertable do
  @moduledoc """
  Alertable protocol is used by `Tux.Show` to display command error results
  in a user-friendly fashion using the `Tux.Alert` struct.

  The protocol is implemented for the following types:

    * **Strings** – alertable is implemented for strings, so that if you return
    `{:error, "some message"}` from a command, the message will be shown as
    a `Tux.Alert`.

    * **Tux.Error** - alertable is also implemented for the `Tux.Error` struct
    or any struct which is constructed with `use Tux.Error`, so that if you return
    `{:error, %Tux.Error{}}` or `{:error, %MyDerivedError{}}` from a command,
    the struct will be shown as a `Tux.Alert`.

    * **Exceptions** - alertable is implemented for the Elixir `Exception` structs
      and will extract the `:message` field as the alert's title. Thus, if your app
      throws an exception and the dispatcher is using the options `rescue: true`,
      the thrown exception will be shown as an alert.

  """

  @fallback_to_any true

  @doc "The title of the alert"
  def title(_)

  @doc "The detailed message of the alert"
  def message(_)
end

defimpl Tux.Alertable, for: BitString do
  def title(string), do: string
  def message(_str), do: nil
end

defimpl Tux.Alertable, for: Any do
  defmacro __deriving__(module, %{__tuxexception__: true}, _options) do
    quote do
      defimpl Tux.Alertable, for: unquote(module) do
        def title(error), do: error.message
        def message(error), do: error.details
      end
    end
  end

  ## Title

  def title(term) when is_struct(term) do
    case Map.from_struct(term) do
      %{__exception__: true} ->
        "#{Macro.to_string(term.__struct__)}"

      struct ->
        raise_impl_missing(struct)
    end
  end

  def title(term),
    do: raise_impl_missing(term)

  ## Message

  def message(term) when is_struct(term) do
    case Map.from_struct(term) do
      # Tux.Error exceptions
      %{__exception__: true, message: message} ->
        message

      # Regular Elixir exceptions
      %{__exception__: true} ->
        "#{inspect(term)}"

      struct ->
        raise_impl_missing(struct)
    end
  end

  def message(term), do: raise_impl_missing(term)

  def raise_impl_missing(term) do
    raise Tux.Errors.NotImplementedError,
      message: """
      `Tux.Alertable` is not implemented for the `#{inspect(term)}`
      """
  end
end

defmodule Tux.Alert do
  @moduledoc """
  An alert is a struct which encodes the textual and formatting information
  which can be used to display stylized error messages.

  ## Examples

  Please be aware that the colored and embolden parts cannot be seen in this example,
  nonetheless an alert in its simplest version looks roughly something like this:

  ```sh
  │ ERR: Command error
  ```

  And with additional details:

  ```sh
  │ ERR: Command error
  │
  │ This section has more details about the error.
  ```
  """

  @typedoc """
  The alert struct
  """
  @type t :: %__MODULE__{
          tag: String.t(),
          color: fun(),
          title: String.t(),
          message: String.t()
        }

  defstruct tag: nil,
            color: nil,
            title: nil,
            message: nil

  @doc """
  Return a blank alert struct

  ## Examples

      iex> Tux.Alert.new()
      %Tux.Alert{tag: nil, color: nil, title: nil, message: nil}

  """
  @spec new() :: t()
  def new() do
    struct!(__MODULE__)
  end

  @type field :: :tag | :color | :title | :message
  @type value :: String.t() | fun()

  @doc """
  Set or update a given alert field.

  ## Examples

      iex> alias Tux.Alert
      ...>
      ...> Alert.new()
      ...> |> Alert.add(:tag, "ERR")
      ...> |> Alert.add(:color, &Tux.Colors.red/1)
      ...> |> Alert.add(:title, "Title")
      ...> |> Alert.add(:message, "Message")
      %Tux.Alert{color: &Tux.Colors.red/1, message: "Message", tag: "ERR", title: "Title"}

  """
  @spec add(t, field, value) :: t()
  def add(alert, :tag, tag) when is_binary(tag) do
    %{alert | tag: tag}
  end

  def add(alert, :color, color) when is_function(color) do
    %{alert | color: color}
  end

  def add(alert, :title, title) when is_binary(title) do
    %{alert | title: title}
  end

  def add(alert, :message, message) do
    %{alert | message: message}
  end
end

defimpl String.Chars, for: Tux.Alert do
  alias Tux.Alert
  import Tux.Colors, only: [bold: 1]

  @doc """
  Return the string representation of an alert.
  """
  def to_string(%Alert{tag: tag, title: title, message: nil} = a)
      when is_binary(tag) and is_binary(title) do
    """

     #{a.color.("│")} #{bold(a.color.("#{a.tag}:"))} #{bold(a.title)}
    """
  end

  def to_string(%Alert{tag: tag, title: title, message: message} = a)
      when is_binary(tag) and is_binary(title) and is_binary(message) do
    expand = fn message ->
      message
      |> String.split("\n")
      |> Enum.reduce("", fn line, acc ->
        acc <>
          " #{a.color.("│")} #{line}\n"
      end)
    end

    """

     #{a.color.("│")} #{bold(a.color.("#{a.tag}:"))} #{bold(a.title)}
     #{a.color.("│")}
    """ <>
      expand.(message)
  end
end
