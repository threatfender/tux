# Tux

[Official Site](https://tuxlib.dev/)
– [Docs](https://hexdocs.pm/tux/readme.html)
– [Examples](https://github.com/threatfender/tux/tree/master/examples)

<img src="assets/logo.png"/>

*Terminal User Experience*

Tux is a **modular**, **dependency-free** Elixir library
designed for the speedy creation of elegant command line interfaces
which subscribe to the philosophy *"One module per command"*.

Its modular structure ensures its core functionalities can be overwritten
and composed to fulfill custom needs, and having no dependencies means it can
achieve a higher level of security by minimizing trusted parties.

## Installation

Add `tux` to your list of dependencies in `mix.exs` and optionally update
your `.formatter.exs`:

```
# mix.exs
{:tux, "~> 0.3.0"}

# .formatter.exs
import_deps: [:tux]
```

## Example

Here's a very short example to illustrate the mechanics of the library,
although keep in mind that tux has more features, among which: `command preloads`, `nested commands`, `command alerts`, `help messages`, `command testing` and more.

1. A **command module** implements a command:

```elixir
defmodule Demo.HelloCmd do
  use Tux.Command

  @impl true
  def about(), do: "Greet current user"

  @impl true
  def main(env, args), do: {:ok, "Hello #{env.pre.user}!"}
end
```

2. A **dispatcher module** groups commands together:

```elixir
defmodule Demo do
  use Tux.Dispatcher

  # Command registration
  cmd "hello", Demo.HelloCmd, preloads: [:user]
  cmd "adios", Demo.AdiosCmd
  cmd "group", Demo.AnotherDispatcher

  # Preloads can be executed before each command that registers them
  def user(_), do: System.fetch_env!("USER")
end
```

3. **Test** your escript with the supplied testing macros:

```elixir
defmodule DemoTest do
  use Tux.Case

  scenario "check greet command",
    using: Demo,
    invoke: "hello",
    expect: [approx: "Hello"]
end
```

4. **Build** your elixir app as an escript, just make sure to add the
 `escript: [main_module: Demo]` to the `:project` section of your `mix.exs`.
 See [mix escript.build](https://hexdocs.pm/mix/main/Mix.Tasks.Escript.Build.html) for more details.

```sh
$ mix escript.build
Generated escript demo

$ ./demo hello
Hello tuxuser!
```

## Next Steps

  * Visit the [official site](https://tuxlib.dev)
  * Read the [docs](https://hexdocs.pm/tux) on HexDocs
  * Look into the [examples](https://github.com/threatfender/tux/tree/master/examples) folder for complete escripts

## License

Tux is open source software licensed under the Apache 2.0 License.
