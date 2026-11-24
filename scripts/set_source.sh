#!/bin/bash
# Puts the public zip URL and its sha256 into DaVoiceOnnxRuntime.podspec (run after uploading the zip).
# Usage: scripts/set_source.sh https://<public host>/DaVoiceOnnxRuntime-1.31.0.zip [path/to/the/same.zip]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
URL="$1"
VERSION="$(sed -n "s/^ *s.version *= *'\(.*\)'/\1/p" "$ROOT/DaVoiceOnnxRuntime.podspec")"
ZIP="${2:-$ROOT/dist/DaVoiceOnnxRuntime-$VERSION.zip}"
SHA="$(shasum -a 256 "$ZIP" | cut -d' ' -f1)"
# The uploaded file must be the same bytes as the local zip.
REMOTE="$(curl -fsSL "$URL" | shasum -a 256 | cut -d' ' -f1)"
[ "$REMOTE" = "$SHA" ] || { echo "The file at $URL ($REMOTE) is not $ZIP ($SHA)" >&2; exit 1; }
sed -i '' "s|s.source       = { :http => '[^']*', :sha256 => '[^']*' }|s.source       = { :http => '$URL', :sha256 => '$SHA' }|" "$ROOT/DaVoiceOnnxRuntime.podspec"
grep -n "s.source " "$ROOT/DaVoiceOnnxRuntime.podspec"
