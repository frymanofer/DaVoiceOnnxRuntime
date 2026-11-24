#!/bin/bash
# Packs the pod zip from the output of build_ort.sh (the official staging folders):
#   onnxruntime.xcframework, Headers/ (C/C++ API), objectivec/ (Objective-C API sources, no tests),
#   LICENSE, ThirdPartyNotices.txt  ->  dist/DaVoiceOnnxRuntime-<version>.zip (files at the zip root)
# Usage: scripts/make_pod_zip.sh [staging dir]   (default: build/staging)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STAGING="${1:-$ROOT/build/staging}"
VERSION="$(sed -n "s/^ *s.version *= *'\(.*\)'/\1/p" "$ROOT/DaVoiceOnnxRuntime.podspec")"
C="$STAGING/onnxruntime-c"; OBJC="$STAGING/onnxruntime-objc"
[ -d "$C/onnxruntime.xcframework" ] && [ -d "$OBJC/objectivec" ] || { echo "No ORT staging output in $STAGING" >&2; exit 1; }
grep -q "\"$VERSION\"" "$C/onnxruntime-c.podspec" || { echo "Staging is not ORT $VERSION" >&2; exit 1; }

WORK="$(mktemp -d "$ROOT/dist/.zip.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
cp -a "$C/onnxruntime.xcframework" "$C/Headers" "$WORK/"
mkdir -p "$WORK/objectivec/include"
cp -a "$OBJC"/objectivec/*.h "$OBJC"/objectivec/*.mm "$WORK/objectivec/"
cp -a "$OBJC"/objectivec/include/*.h "$WORK/objectivec/include/"
cp "$ROOT/LICENSE" "$ROOT/ThirdPartyNotices.txt" "$WORK/"
find "$WORK" -name .DS_Store -delete

OUT="$ROOT/dist/DaVoiceOnnxRuntime-$VERSION.zip"
rm -f "$OUT"
(cd "$WORK" && zip -qry -X "$OUT" .)
echo "$OUT"
echo "sha256 $(shasum -a 256 "$OUT" | cut -d' ' -f1)"
echo "size   $(du -h "$OUT" | cut -f1)"
