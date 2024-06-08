defmodule Tux.Show do
  @moduledoc """
  This module is responsible for converting the `Tux.Result` returned by a command
  module to a string representation, and then sending it to the device (by default
  the :stdio) defined in the `Tux.Env` struct.

  In the case a command returns non-successful results (e.g. errors, warnings)
  this module will extract the appropriate information they carry via the
  `Tux.Alertable` protocol.
  """
  alias Tux.Alert
  alias Tux.Colors
  alias Tux.Alertable
  alias Tux.Env
  alias Tux.Result

  @typedoc """
  A term convertible to a string
  """
  @type stringable :: String.Chars.t()

  @typedoc """
  A device as supported by the `IO` module.
  """
  @type device :: IO.device()

  @doc """
  Write the result returned by a command module
  to the device defined in that command's env.
  """
  @callback show(env :: Env.t(), result :: Result.t()) :: :ok

  @doc """
  Write a string-able item to a IO device with or without a newline.

  ## Examples

      Tux.Show.write("something", :stdio, true)
      something
      :ok

      Tux.Show.write("something", :stdio, false)
      something:ok

  """
  @spec write(stringable, device, boolean) :: :ok
  def write(stringable, device, newline) do
    case newline do
      true -> IO.write(device, "#{stringable}\n")
      false -> IO.write(device, stringable)
    end
  end

  @doc """
  Write a command result to the IO device.

  ### Caveats

    * When the given result is `:ok`, it writes only an empty string and no newline,
      irrespective of whether the env's newline was set to `true`,
      because such a result means the command was successful
      but no other information was returned.

    * When the given result is `{:ok, term}`, then it will append a newline to the term
      only if the `use Tux.Dispatcher, newline: true` was set. Note that this
      is the default behaviour so there's no need to set `newline: true`,
      however you can optionally prevent newlines from being written
      by specifying `newline: false` when `use`ing the Dispatcher.

    * The result `{:error, term}` will be shown as `Tux.Alert`

    * Note that you can also overwrite `show/2` in your own command module
      this way you have full control over how any particalar command
      displays its results.

  """
  @spec show(Env.t(), Result.t()) :: :ok
  def show(env, :ok) do
    write("", env.dev, false)
  end

  def show(env, :error) do
    Alert.new()
    |> Alert.add(:tag, "ERR")
    |> Alert.add(:color, &Colors.red/1)
    |> Alert.add(:title, "Command Returned Just Error")
    |> write(env.dev, env.new)
  end

  def show(env, {:ok, stringable}) do
    case to_string(stringable) do
      "" ->
        show(env, :ok)

      str ->
        write(str, env.dev, env.new)
    end
  end

  def show(env, {:error, atom}) when is_atom(atom) do
    message = "An error occured"
    details = "#{inspect(atom)}"
    show(env, {:error, %Tux.Error{message: message, details: details}})
  end

  def show(env, {:error, explainable}) do
    Alert.new()
    |> Alert.add(:tag, "ERR")
    |> Alert.add(:color, &Colors.red/1)
    |> Alert.add(:title, Alertable.title(explainable))
    |> Alert.add(:message, Alertable.message(explainable))
    |> write(env.dev, env.new)
  end

  @doc """
  This is used internally by the `Tux.Dispatcher` and `Tux.Command`
  to inject the show routines.
  """
  defmacro __using__(opts \\ []) do
    quote do
      alias Tux.Env
      alias Tux.Result
      alias Tux.Show

      @doc """
      Print the final result to the `env.dev` device.
      This function can be overwritten inside the module which uses `Tux.Show`,
      for more specialized needs.

      ### Exception Raising

      If the show function is invoked with an invalid `Tux.Result` shape,
      it will raise a `RuntimeError` exception describing the problem.
      """
      @spec show(Env.t(), Result.t()) :: :ok

      ## Result is an atom
      def show(env, :ok), do: Show.show(env, :ok)
      def show(env, :error), do: Show.show(env, :error)

      ## Result is a tuple
      def show(env, {:ok, term}), do: Show.show(env, {:ok, term})
      def show(env, {:error, term}), do: Show.show(env, {:error, term})

      ## All other results should raise
      def show(env, term), do: Tux.Result.raise_invalid_result_type(env, term)

      if Keyword.get(unquote(opts), :overridable) do
        defoverridable show: 2
      end
    end
  end
end
