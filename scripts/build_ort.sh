#!/bin/bash
# Builds ONNX Runtime for iOS from source with Microsoft's own Apple packaging script and our settings
# (scripts/ios_build_settings.json: CoreML + XNNPACK, iOS 15.1, device arm64, simulator arm64 + x86_64).
# Takes about 30 minutes on 4 cores and several GB of disk.
#
# Usage: scripts/build_ort.sh [work dir]   (default: build/)
# The source is the v1.31.0 commit. Microsoft's GitHub repo was taken down in November 2026; the same commit
# is in public mirrors (git checks every object against the commit hash), e.g. github.com/intel/onnxruntime.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${1:-$ROOT/build}"
VERSION="$(sed -n "s/^ *s.version *= *'\(.*\)'/\1/p" "$ROOT/DaVoiceOnnxRuntime.podspec")"
COMMIT=402979ac1bef89dcd55add41eaa7277c407599eb      # v1.31.0
MIRROR="${ORT_MIRROR:-https://github.com/intel/onnxruntime.git}"
mkdir -p "$WORK"
if [ ! -d "$WORK/onnxruntime/.git" ]; then
  git -C "$WORK" init -q onnxruntime
  git -C "$WORK/onnxruntime" fetch --depth 1 "$MIRROR" "$COMMIT"
  git -C "$WORK/onnxruntime" checkout -q FETCH_HEAD
  git -C "$WORK/onnxruntime" submodule update --init --depth 1
fi
[ "$(git -C "$WORK/onnxruntime" rev-parse HEAD)" = "$COMMIT" ] || { echo "Source is not $COMMIT" >&2; exit 1; }
cd "$WORK/onnxruntime"
python3 tools/ci_build/github/apple/build_and_assemble_apple_pods.py \
  --build-dir "$WORK/build" --staging-dir "$WORK/staging" \
  --pod-version "$VERSION" --build-settings-file "$ROOT/scripts/ios_build_settings.json"
echo "Staging: $WORK/staging   (next: scripts/make_pod_zip.sh $WORK/staging)"
