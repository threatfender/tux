# Tux Changelog

## v0.4.0 – June 2024

  * Include dispatcher preloads in the final command preloads.
  * Refactor and improve `Tux.Dispatcher`.
  * Rename Tux.Error `:exit_code` to `:exitcode`.
  * Rename `Tux.Explainable` protocol to `Tux.Alertable`.
  * Replace demo example with recon.
  * Rename Tux.Quick `module` macro to `program`.
  * Remove `:warn` type from the `Tux.Result`.
  * Add `Tux.Exit` module for controlling exits.
  * Move all errors in the `Tux.Errors` module.
  * Remove `Tux.Commands.NotImplemented`.
  * Show both choices when using `Prompt.for_confirmation`.
  * Emit `ConfigReadError` and `ConfigWriteError` on bang config functions.
  * Add new dispatcher option `:exitwith` with possible values `:halt` or `:stop`.
  * Exit with non-zero status when command modules return errors.

## v0.3.5 – February 2024

  * Update `pre` macro to accept a single command.
  * Add compile-time checks for conflicting command names.
  * Add `cmd` support for prefixed commands via `sigil_p`.

## v0.3.0 – January 2024

  * Update the `cmd` macro to allow registration of multiple names for a command:
    e.g. `cmd ~w(name another_name), CmdModule`.
  * Add support for cumulative preloads when using nested dispatchers,
    by merging preloads down the command hierarchy.
  * Rename the command module callback from `info/0` to `about/0`
  * Add `Tux.Commands.NotImplemented`, which can be used as a
    placeholder command module when one hasn't been implemented yet.
  * Add the `pre/2` macro to simplify the registration of commands
    with common preloads.

## v0.2.0 – December 2023

  * Add `Tux.Init`, `Tux.Exec` & `Tux.Show` as separate stages in a command life cycle
  * Add `Tux.Env` struct for storing preloads returns and command context
  * Add `Tux.Colors` for writing colored output
  * Add `Tux.Prompt` for user prompting (ints, floats, strings) and confirmations
  * Add `Tux.Config` for reading and writing simple `key = value` config files
  * Add `Tux.Explainable` protocol as a source for alerts
  * Add `Tux.Alert` for displaying warnings and errors
  * Add `Tux.Error` for creating displayable errors
  * Add `Tux.Help` for creating help messages
  * Add `Tux.Result` for validating returns of commands
  * Add `Tux.Command` for creating command modules
  * Add `Tux.Dispatcher` for creating dispatcher modules and registering
    command modules with `cmd/3` macro.

## v0.1.0

  * Initial commit
