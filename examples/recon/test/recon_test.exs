defmodule ReconTest do
  use Tux.Case, async: false

  scenario "init cmd",
    using: Recon,
    invoke: "init",
    expect: [approx: "Initialized"]

  scenario "show usage cmd",
    using: Recon,
    invoke: "usage show",
    expect: [approx: "DNS Scans:"]

  scenario "scan dns cmd",
    using: Recon,
    invoke: "scan dns",
    expect: [approx: "[ok]"]
end
