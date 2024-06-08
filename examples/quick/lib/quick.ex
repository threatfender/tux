defmodule Quick do
  @moduledoc """
  An escript with the following layout:

  ./quick
     ping
     greet
       hello
       bye
  """
  import Tux.Quick

  program "main" do
    command "ping", do: {:ok, "pong"}

    dispatcher "greet" do
      command "hello", do: {:ok, "Hello there!"}
      command "bye", do: {:ok, "So long!"}
    end
  end

  defdelegate main(args), to: program("main")
end
