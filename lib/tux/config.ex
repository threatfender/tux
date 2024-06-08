defmodule Tux.Config do
  @moduledoc """
  Basic support for reading and writing `key = value` configuration files,
  with support for ignoring comment lines (lines that start with `#`
  or `;`).

  ## Example

  Say you have an existing configuration file *file.conf*:

  ```bash
  # This is a comment line (will be ignored)
  path = /tmp

  # Note that all values will be parsed as strings
  rounds = 10

  ; Windows-style comments are also ignored,
  ; and so are these [sections]
  [couting]
  count = 123
  ```

  You can read it with `read_file/2`:

  ```
  with {:ok, config} <- Tux.Config.read_file("file.conf") do
    assert config["path"] == "/tmp"
    assert config["rounds"] == "10"
    assert config["count"] == "123"
  end
  ```

  ### Notes

    * All read values will be strings.
    * All read valeus which are empty strings will be converted to nil.

  """

  @typedoc """
  Options passed to `read_file/2`.
  """
  @type read_opts :: [keys: :strings | :atoms | :atoms!]

  @doc """
  Read a configuration file located at a given path.

  ## Options:

    * `:keys` - control how configuration keys are parsed:
      * `:strings` (default) - keys are converted to strings
      * `:atoms` - keys are converted to atoms using `String.to_atom/1`
      * `:atoms!` - keys are converted to atoms using `String.to_existing_atom/1`

  """
  @spec read_file(Path.t(), read_opts()) :: {:ok, map()} | {:error, any()}
  def read_file(file, opts \\ []) do
    key_converter =
      case Keyword.get(opts, :keys, :strings) do
        :strings -> fn key -> key end
        :atoms -> fn key -> String.to_atom(key) end
        :atoms! -> fn key -> String.to_existing_atom(key) end
      end

    with true <- File.exists?(file),
         {:ok, contents} <- File.read(file) do
      contents
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim(&1))
      # Ignore comments or empty lines
      |> Enum.reject(&(String.starts_with?(&1, ["#", ";", "["]) or &1 == ""))
      |> Enum.map(&String.split(&1, "=", parts: 2))
      |> Enum.map(fn [key, val] ->
        {
          key |> String.trim() |> key_converter.(),
          val |> String.trim()
        }
      end)
      # Convert empty values to nils
      |> Enum.map(fn {key, val} -> {key, if(val == "", do: nil, else: val)} end)
      |> Enum.into(%{})
      |> (fn data -> {:ok, data} end).()
    else
      false ->
        {:error, :file_not_found}

      error ->
        error
    end
  end

  @doc """
  Read a configuration file, but raise an exception if the operation fails.
  """
  @spec read_file!(Path.t(), read_opts()) :: map() | no_return()
  def read_file!(file, opts \\ []) do
    case read_file(file, opts) do
      {:ok, config} ->
        config

      error ->
        raise Tux.Errors.ConfigReadError,
          message: "Failed to read #{file} because: #{inspect(error)}"
    end
  end

  @doc """
  Write configuration data to a file.

  The file is created if it does not exist, and if it does exist,
  the previous content is overwritten.
  """
  @spec write_file(Path.t(), map()) :: :ok | {:error, File.posix()}
  def write_file(file, data) when is_map(data) do
    data
    |> Enum.map(fn {key, value} -> "#{key} = #{value}" end)
    |> Enum.join("\n")
    |> (fn contents -> contents <> "\n" end).()
    |> (fn contents -> File.write(file, contents) end).()
  end

  @doc """
  Write configuration data to a file, but raise an exception
  if the operation fails.

  The file is created if it does not exist, and if it does exist,
  the previous content is overwritten.
  """
  @spec write_file!(Path.t(), map()) :: :ok | no_return()
  def write_file!(file, data) when is_map(data) do
    case write_file(file, data) do
      :ok ->
        :ok

      {:error, error} ->
        raise Tux.Errors.ConfigWriteError,
          message: "Failed to write #{file} because: #{inspect(error)}"
    end
  end
end
