# Recon

Recon is a demo Elixir app to illustrate the usage of the `:tux` library.

This demo script "scans" the DNS, SSL and WEB aspects
of a list of endpoints.

## Run

To demo all commands use the shell script:

```
$ ./run_all.sh
```

Alternatively, you can build and try out the demo command manually:

```
# Build escript
$ mix escript.build

# Run recon command
$ ./bin/recon

```

## Layout

Here's the layout of the recon escript:


```
recon
│─ init                - Command to create a default configuration file
│
│─ scan
│    │─ dns            - Command to scan DNS records
│    │─ ssl            - Command to scan SSL certificate
│    └─ web            - Command to scan WEB endpoints
│
│─ endpoint
│    │─ local
│    │    │─ add       - Command to add local endpoint
│    │    │─ remove    - Command to remove local endpoint
│    │    └─ list      - Command to list local endpoints
│    │
│    └─ remote
│         │─ add       - Command to add remote endpoint (not implemented)
│         │─ del       - Command to remove remote endpoint (not implemented)
│         └─ list      - Command to list remote endpoints (not implemented)
│
└─ usage
    │─ show           - Command to show usage stats
    └─ reset          - Command to reset usage stats
```
