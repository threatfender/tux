# Quick

An escript Elixir app, illustrating the usage `Tux.Quick` of
the `:tux` library for quickly generating simple commands:

## Test

Test commands using `Tux.Case`:

```sh
$ mix test
```

## Build

Build the escript:

```sh
$ mix escript.build
```

## Run

Run commands

```sh
$ ./quick ping
pong

$ ./quick greet hello
Hello there!

$ ./quick greet bye
So long!
```
