defmodule Tux.PromptTest do
  use ExUnit.Case
  doctest Tux.Prompt

  alias Tux.Prompt
  import ExUnit.CaptureIO, only: [capture_io: 1, capture_io: 2]

  defmacrop enter(answer, whenever: prompted, expect: expected) do
    quote do
      capture_io(unquote(answer), fn ->
        result = unquote(prompted)
        assert result == unquote(expected)
      end)
    end
  end

  test "integer prompting" do
    enter "21\n",
      whenever: Prompt.for_integer("What is your age"),
      expect: {:ok, 21}

    enter "\n",
      whenever: Prompt.for_integer("What is your age", 100),
      expect: {:ok, 100}

    enter "101\n",
      whenever: Prompt.for_integer("What is your age", 100),
      expect: {:ok, 101}

    enter "bad_number",
      whenever: Prompt.for_integer("What is your age"),
      expect: :error
  end

  test "float prompting" do
    enter "21.01\n",
      whenever: Prompt.for_float("What is your salary"),
      expect: {:ok, 21.01}

    enter "\n",
      whenever: Prompt.for_float("What is your salary", 100.01),
      expect: {:ok, 100.01}

    enter "100.11\n",
      whenever: Prompt.for_float("What is your salary", 100.01),
      expect: {:ok, 100.11}

    enter "bad_number",
      whenever: Prompt.for_float("What is your salary"),
      expect: :error
  end

  test "string prompting" do
    enter "xyz\n",
      whenever: Prompt.for_string("What is your name"),
      expect: {:ok, "xyz"}

    enter " xyz \n",
      whenever: Prompt.for_string("What is your name"),
      expect: {:ok, "xyz"}

    enter "\n",
      whenever: Prompt.for_string("What is your name", "Joe Doe"),
      expect: {:ok, "Joe Doe"}

    enter "Jane Doe\n",
      whenever: Prompt.for_string("What is your name", "Joe Doe"),
      expect: {:ok, "Jane Doe"}
  end

  test "confirmation prompting" do
    enter "yes\n",
      whenever: Prompt.for_confirmation("Confirm this action"),
      expect: true

    enter "no\n",
      whenever: Prompt.for_confirmation("Confirm this action"),
      expect: false

    enter "\n",
      whenever: Prompt.for_confirmation("Confirm this action"),
      expect: false

    enter "\n",
      whenever: Prompt.for_confirmation("Confirm this action", :yes),
      expect: true

    enter "true\n",
      whenever: Prompt.for_confirmation("Confirm this action"),
      expect: false
  end

  test "default choice is capitalized" do
    assert capture_io("some answer\n", fn ->
             Prompt.for_confirmation("Continue", :no)
           end) == "Continue [yes/NO]: "

    assert capture_io("some answer\n", fn ->
             Prompt.for_confirmation("Continue", :yes)
           end) == "Continue [no/YES]: "
  end
end
