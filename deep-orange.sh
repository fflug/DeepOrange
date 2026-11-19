#!/bin/sh
# Starts the UCI engine with the local Dyalog installation. Register this
# file as the engine command in a chess GUI, with protocol UCI.

# GUI applications on macOS do not inherit the shell's PATH, so the usual
# install locations are searched when dyalogscript is not on it. Set
# DYALOGSCRIPT to its full path if none of them match.
if [ -z "$DYALOGSCRIPT" ]; then
    DYALOGSCRIPT="$(command -v dyalogscript)"
fi
for candidate in /usr/local/bin/dyalogscript /opt/homebrew/bin/dyalogscript; do
    [ -n "$DYALOGSCRIPT" ] && break
    [ -x "$candidate" ] && DYALOGSCRIPT="$candidate"
done

exec "$DYALOGSCRIPT" "$(dirname "$0")/uci.apls"
