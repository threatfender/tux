defmodule Testo do
  @moduledoc false
  use Tux.Dispatcher

  cmd "ping", Testo.PingCmd
  cmd "exit", Testo.ExitCmd
  cmd "bump", Testo.BumpDsp
end
