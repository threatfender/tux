defmodule Testo.ExitCmd do
  @moduledoc false
  use Tux.Command

  @error %Tux.Error{message: "Exit code should be 3", exitcode: 3}

  @impl true
  def main(_, _), do: {:error, @error}
end
