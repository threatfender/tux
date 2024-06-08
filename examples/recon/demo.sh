#!/usr/bin/env sh

# Colors
Bold="\033[1m"
Reset="\033[0m"

info(){
    printf "$Bold%s$Reset\n" "$1"
}

# Build escript
mix deps.get
mix test
mix escript.build

# Run commands
echo ""
info "./bin/recon" \
   && ./bin/recon

echo ""
info "./bin/recon init" \
   && ./bin/recon init

echo ""
info "./bin/recon endpoint --help" \
   && ./bin/recon endpoint --help

echo ""
info "./bin/recon endpoint local list" \
   && ./bin/recon endpoint local list

echo ""
info "./bin/recon endpoint local list --json" \
   && ./bin/recon endpoint local list --json

echo ""
info "./bin/recon endpoint local add" \
   && ./bin/recon endpoint local add

echo "* Okay! Let's try again with the --name option given:"
info "./bin/recon endpoint local add --name google.com" \
   && ./bin/recon endpoint local add --name google.com

echo ""
info "./bin/recon endpoint local list" \
   && ./bin/recon endpoint local list

echo ""
info "./bin/recon endpoint local remove --name google.com" \
   && ./bin/recon endpoint local remove --name google.com

echo ""
info "./bin/recon endpoint local list" \
   && ./bin/recon endpoint local list

echo ""
info "./bin/recon scan dns" \
   && ./bin/recon scan dns

echo ""
info "./bin/recon scan ssl" \
   && ./bin/recon scan ssl

echo ""
info "./bin/recon scan web" \
   && ./bin/recon scan web

echo ""
info "./bin/recon usage show" \
   && ./bin/recon usage show
