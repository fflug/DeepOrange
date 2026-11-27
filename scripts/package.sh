#!/usr/bin/env bash
# Builds the release archive of the engine: the engine sources, the UCI
# script and its launcher, without the tests.
#
# Usage: scripts/package.sh VERSION [OUT_DIR]
#
# Writes OUT_DIR/deep-orange-VERSION.zip (OUT_DIR defaults to dist), which
# unpacks to a single directory deep-orange-VERSION. That directory is a
# baseline for scripts/match.sh.

set -euo pipefail

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    sed -n '2,/^$/s/^# \{0,1\}//p' "$0" >&2
    exit 2
fi

root="$(cd "$(dirname "$0")/.." && pwd)"
version="$1"
out="$(mkdir -p "${2:-dist}" && cd "${2:-dist}" && pwd)"
name="deep-orange-$version"

staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT

mkdir -p "$staging/$name/APLSource"
cp -R "$root/APLSource/DeepOrange" "$staging/$name/APLSource/"
cp "$root/uci.apls" "$root/deep-orange.sh" "$root/LICENSE" "$root/README.md" "$staging/$name/"
chmod +x "$staging/$name/deep-orange.sh"

rm -f "$out/$name.zip"
(cd "$staging" && zip -qr "$out/$name.zip" "$name")
echo "$out/$name.zip"
