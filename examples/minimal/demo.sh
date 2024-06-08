#!/usr/bin/env sh

echo "* BUILD ..."     && mix do deps.get + escript.build
echo ""
echo "* RUN COMMANDS ..."
echo ""
echo "./minimal ping"  && ./minimal ping
echo "./minimal hello" && ./minimal hello
echo ""
echo "* CLEAN UP ..."  && rm -rf _build minimal \
                       && echo "Done."
