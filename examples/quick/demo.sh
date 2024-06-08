#!/usr/bin/env sh

echo "* BUILD ..."         && mix do deps.get + escript.build
echo ""
echo "* RUN COMMANDS ..."
echo ""
echo "./quick ping"        && ./quick ping
echo "./quick greet hello" && ./quick greet hello
echo "./quick greet bye"   && ./quick greet bye
echo ""
echo "* CLEAN UP ..."      && rm -rf _build quick \
                           && echo "Done."
