defmodule Tux.Error do
  @moduledoc """
  Construct custom exception modules which automatically derive the
  `Tux.Alertable` protocol. The generated error type will have the
  following fields:

    * `:message`   - short error message which will be used as title
    * `:details`   - detailed explanation of the error (.e.g. info about possible
      resolutions, etc)
    * `:exitcode` - exit code to be used at escript's termination

  ## Use Options

  When constructing new error modules with `use Tux.Error`, the following
  options are available:

    * `:message` (required) – main error message to use for the struct
    * `:exitcode` (optional) – exit code (default is 1)

  ### Examples

      defmodule MyError do
        use Tux.Error, message: "MyError Occurred"
      end

      defmodule MyOtherError do
        use Tux.Error, message: "MyError Occurred", exitcode: 100
      end

  Now you can raise or return the error from your command modules:

      raise MyError
      {:error, %MyError{...}}

  A useful idea is to define a `new/1` function in your error module
  which accepts specific information and constructs a more detailed error:

      defmodule FieldError do
        use Tux.Error, message: "Field is Missing"

        def new(fieldname: fieldname) do
          struct!(__MODULE__, details: \"\"\"
          The \#{red(fieldname)} is missing.
          \"\"\")
        end
      end

  Here's how the `Tux.Alertable` protocol behaves when
  invoked with a tux error struct:

      defmodule MyError do
        use Tux.Error, message: "Some Error Occurred"
      end

      error = %MyError{}
      assert Tux.Alertable.title(error) == "Some Error Occurred"
      assert Tux.Alertable.message(error) == nil

      error = MyError{details: "This error is really, really bad."}
      assert Tux.Alertable.title(error) == "Some Error Occurred"
      assert Tux.Alertable.message(error) == "This error is really, really bad."
  """

  @derive Tux.Alertable
  defexception [
    # A custom field to signal this is a tux exception
    {:__tuxexception__, true},

    # Short error message
    message: nil,

    # Detailed error information
    details: nil,

    # Exit code to use for command termination
    exitcode: 1
  ]

  @typedoc """
  Options given to `use Tux.Error`
  """
  @type opts :: [message: String.t(), exitcode: integer()]

  @doc """
  Implement the functionality for `use Tux.Error`.
  """
  defmacro __using__(opts) do
    quote do
      @derive Tux.Alertable
      defexception [
        {:__tuxexception__, true},
        {:message, Keyword.fetch!(unquote(opts), :message)},
        {:details, nil},
        {:exitcode, Keyword.get(unquote(opts), :exitcode, 1)}
      ]

      # Import colors as we might used them when
      # we construct the `details` field.
      import Tux.Colors

      @doc """
      Return a new default error struct.
      """
      def new(), do: struct!(__MODULE__)
    end
  end
end
