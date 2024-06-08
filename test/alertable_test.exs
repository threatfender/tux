defmodule Tux.AlertableTest do
  use ExUnit.Case
  alias Tux.Alertable
  alias Tux.Errors
  alias Tux.Error

  describe "explainable protocol for" do
    test "elixir errors" do
      error = %RuntimeError{}
      assert Alertable.title(error) == "RuntimeError"
      assert Alertable.message(error) == "runtime error"

      error = %RuntimeError{message: "A really bad error occurred"}
      assert Alertable.title(error) == "RuntimeError"
      assert Alertable.message(error) == "A really bad error occurred"

      error = %MatchError{}
      assert Alertable.title(error) == "MatchError"
      assert Alertable.message(error) == "%MatchError{term: nil}"
    end

    test "strings" do
      str = "some message"
      assert Alertable.title(str) == "some message"
      assert Alertable.message(str) == nil
    end

    test "tux base error" do
      error = %Error{message: "Some error"}
      assert Alertable.title(error) == "Some error"
      assert Alertable.message(error) == nil
    end

    test "tux command errors" do
      env = %Tux.Env{cmd: "some-cmd"}
      error = Errors.CommandRescuedError.new(env: env)
      assert Alertable.title(error) == "Command Failure"
      assert Alertable.message(error) =~ "some-cmd"
    end
  end

  describe "explain protocol should lack for" do
    defmodule MyStruct do
      defstruct []
    end

    def check_raise_not_implemented(term) do
      assert_raise(Tux.Errors.NotImplementedError, fn ->
        Alertable.title(term)
      end)

      assert_raise(Tux.Errors.NotImplementedError, fn ->
        Alertable.message(term)
      end)
    end

    test "map" do
      map = %{}
      check_raise_not_implemented(map)
    end

    test "struct" do
      s = %MyStruct{}
      check_raise_not_implemented(s)
    end
  end
end
