defmodule Tux.Prompt do
  @moduledoc """
  Helper functions for retrieving user input as: strings, integers, floats
  or for asking for confirmations.

    * Default values will be displayed between `[...]` at the end of the prompt.
    * Supports default values when no value (just enter) is typed.

  ## Examples

      alias Tux.Prompt

      with true <- Prompt.for_confirmation("Really continue"),
           {:ok, name} <- Prompt.for_string("What's your name", "Joe Doe"),
           {:ok, age} <- Prompt.for_string("What's your age"),
           {:ok, salary} <- Prompt.for_float("What's your salary") do
            IO.puts("Name: \#{name}, Age: \#{age}, Salary: \#{salary}")
      end

  """

  @typedoc """
  They type for the prompt message shown to the end user
  asking for a confirmation or some input.
  """
  @type prompt :: String.t()

  @doc """
  Prompt and parse a `yes` or `no` answer:

      Tux.Prompt.for_confirmation("Really delete")
      false

      Tux.Prompt.for_confirmation("Really delete", :yes)
      true

  """
  @spec for_confirmation(prompt, :yes | :no) :: boolean()
  def for_confirmation(prompt, default \\ :no) when default in [:yes, :no] do
    default_choice =
      default
      |> Atom.to_string()
      |> String.upcase()

    opposite_choice =
      %{yes: :no, no: :yes}
      |> Map.fetch!(default)
      |> Atom.to_string()

    case for_string("#{prompt} [#{opposite_choice}/#{default_choice}]") do
      # When user simply types `enter` we return the default confirmation
      {:ok, ""} ->
        flag = Map.get(%{yes: true, no: false}, default)
        flag

      {:ok, value} when value in ["yes", "YES"] ->
        true

      {:ok, value} when value in ["no", "NO"] ->
        false

      {:ok, _} ->
        false
    end
  end

  @doc """
  Prompt and parse an integer answer:

      Tux.Prompt.for_integer("What's your age?")
      {:ok, 25}

      Tux.Prompt.for_integer("What's your age?")
      :error

  """
  @spec for_integer(prompt, nil | integer()) :: {:ok, integer()} | :error
  def for_integer(prompt, default \\ nil) when is_integer(default) or is_nil(default) do
    _get(prompt, default, fn trimmed_input ->
      case Integer.parse(trimmed_input) do
        {number, ""} ->
          {:ok, number}

        _ ->
          :error
      end
    end)
  end

  @doc """
  Prompt and parse a float answer:

      Tux.Prompt.for_integer("What's your salary?")
      {:ok, 25.0}

      Tux.Prompt.for_integer("What's your salary?")
      :error

  """
  @spec for_float(prompt, nil | float()) :: {:ok, float()} | :error
  def for_float(prompt, default \\ nil) when is_float(default) or is_nil(default) do
    _get(prompt, default, fn trimmed_input ->
      case Float.parse(trimmed_input) do
        {number, ""} ->
          {:ok, number}

        _ ->
          :error
      end
    end)
  end

  @doc """
  Prompt and collect a string with the whitespace trimmed:

      Tux.Prompt.for_integer("What's your name?")
      {:ok, "Tux"}

      Tux.Prompt.for_integer("What's your name?", "Joe Doe")
      {:ok, "Joe Doe"}

  """
  @spec for_string(prompt, nil | String.t()) :: {:ok, String.t()}
  def for_string(prompt, default \\ nil) when is_binary(default) or is_nil(default) do
    _get(prompt, default, fn trimmed_input ->
      {:ok, trimmed_input}
    end)
  end

  # Show prompt with its optional default (if any),
  # then transform the user input using the `parser` function.
  defp _get(prompt, default, parser) do
    case default do
      nil ->
        input = "#{prompt}: " |> IO.gets() |> String.trim()
        parser.(input)

      default ->
        input = "#{prompt} [#{default}]: " |> IO.gets() |> String.trim()

        case input do
          "" ->
            {:ok, default}

          string ->
            parser.(string)
        end
    end
  end
end
