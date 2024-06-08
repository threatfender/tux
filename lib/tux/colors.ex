defmodule Tux.Colors do
  @moduledoc """
  Basic functions wrapping a few `IO.ANSI` coloring functions
  for writing stylized output to the terminal.

  `bold/2` `underline/2` + `faint/2` `gray/2`
  `red/2` `orange/2` `yellow/2` `green/2` `blue/2`

  When you `use Tux.Command` this module is imported automatically
  along with the `Tux.Help` module.

  ## Usage

  ```
  import Tux.Colors

  \"\"\"
  This is some \#{bold("bold text")} illustrating the \#{underline("usage")}
  of Tux.Colors module. This \#{red("word", false)} however,
  won't be colored because the second argument passed is false, which is useful
  when you want to control the colored output based on some configuration flag
  passed to the functions in this module.
  \"\"\"
  ```

  """
  alias IO.ANSI, as: Color

  @doc """
  Return text with `underline` style applied
  """
  @spec underline(term) :: String.t()
  def underline(term, enabled \\ true) do
    if enabled,
      do: Color.underline() <> "#{term}" <> Color.reset(),
      else: "#{term}"
  end

  @doc """
  Return the `term` with style applied
  """
  @spec bold(term) :: String.t()
  def bold(term, enabled \\ true) do
    if enabled,
      do: Color.bright() <> "#{term}" <> Color.reset(),
      else: "#{term}"
  end

  @doc """
  Return the `term` with style applied
  """
  @spec red(term) :: String.t()
  def red(term, enabled \\ true) do
    if enabled,
      do: Color.red() <> "#{term}" <> Color.reset(),
      else: "#{term}"
  end

  @doc """
  Return the `term` with style applied
  """
  @spec orange(term) :: String.t()
  def orange(term, enabled \\ true) do
    if enabled,
      do: Color.color(5, 3, 0) <> "#{term}" <> Color.reset(),
      else: "#{term}"
  end

  @doc """
  Return the `term` with style applied
  """
  @spec yellow(term) :: String.t()
  def yellow(term, enabled \\ true) do
    if enabled,
      do: Color.yellow() <> "#{term}" <> Color.reset(),
      else: "#{term}"
  end

  @doc """
  Return the `term` with style applied
  """
  @spec green(term) :: String.t()
  def green(term, enabled \\ true) do
    if enabled,
      do: Color.green() <> "#{term}" <> Color.reset(),
      else: "#{term}"
  end

  @doc """
  Return the `term` with style applied
  """
  @spec blue(term) :: String.t()
  def blue(term, enabled \\ true) do
    if enabled,
      do: Color.blue() <> "#{term}" <> Color.reset(),
      else: "#{term}"
  end

  @doc """
  Return the `term` with style applied
  """
  @spec gray(term) :: String.t()
  def gray(term, enabled \\ true) do
    if enabled,
      do: Color.color(2, 2, 2) <> "#{term}" <> Color.reset(),
      else: "#{term}"
  end

  @doc """
  Return the `term` with style applied
  """
  @spec faint(term) :: String.t()
  def faint(term, enabled \\ true) do
    if enabled,
      do: Color.color(1, 1, 1) <> "#{term}" <> Color.reset(),
      else: "#{term}"
  end
end
