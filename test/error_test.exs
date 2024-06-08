defmodule Tux.ErrorTest do
  use ExUnit.Case
  alias Tux.Errors

  doctest Tux.Error
  doctest Tux.Errors

  test "tux base error" do
    error = %Tux.Error{
      message: "some err",
      details: "some details"
    }

    assert error.exitcode == 1
  end

  test "tux command errors" do
    assert Errors.CommandRescuedError.new()
    assert Errors.CommandRescuedError.new(env: %Tux.Env{})

    assert Errors.CommandNotFoundError.new()
    assert Errors.CommandNotFoundError.new(name: "some command name")
  end

  defmodule KeyMissingError do
    use Tux.Error, message: "Key Missing", exitcode: 100

    def new(name: key) do
      struct!(__MODULE__, details: "The #{key} is missing")
    end
  end

  test "custom error" do
    error = KeyMissingError.new(name: "blue-key")
    assert error.message == "Key Missing"
    assert error.details =~ "is missing"
    assert error.exitcode == 100
  end
end
