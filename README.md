# DaVoiceOnnxRuntime

ONNX Runtime **1.31.0** for iOS in one CocoaPods pod, built by DaVoice from the official source.

## Why

Since November 2026, Microsoft's `onnxruntime-c` and `onnxruntime-objc` pods cannot be installed. Every version
(1.18.0 to 1.30.0) downloads from `download.onnxruntime.ai`, which now serves a certificate for `*.azureedge.net`,
so `pod install` fails. 1.17.3's host returns 404. There is no 1.31 pod at all. A machine that still has a version in
its CocoaPods cache keeps working, which hides the problem.

This pod replaces both of them:

- **The same Objective-C module.** It provides `onnxruntime_objc`, so `import onnxruntime_objc` code works unchanged.
- **The C/C++ API.** Include it as `#include <onnxruntime/onnxruntime_cxx_api.h>`.
- **Execution providers:** CPU, CoreML and XNNPACK.
- **Platforms:** iOS 15.1 and newer. Device arm64, simulator arm64 and x86_64. Static library.

Do not use it together with `onnxruntime-c` / `onnxruntime-objc` in one app. Both would define the same module and
symbols.

## Use

```ruby
# Podfile or podspec
pod 'DaVoiceOnnxRuntime', '1.31.0'          # s.dependency 'DaVoiceOnnxRuntime', '1.31.0'
```

## What is in the zip

| Path | What |
|---|---|
| `onnxruntime.xcframework` | ONNX Runtime static library + C/C++ headers (official build output) |
| `Headers/` | The same C/C++ headers. The Objective-C sources include them by name. |
| `objectivec/` | Microsoft's Objective-C API sources, unchanged (`ORTEnv`, `ORTSession`, …) |
| `LICENSE`, `ThirdPartyNotices.txt` | ONNX Runtime's MIT license and third-party notices |

## Build it again

```bash
scripts/build_ort.sh            # ~30 min: ORT v1.31.0 (commit 402979ac…) with scripts/ios_build_settings.json
scripts/make_pod_zip.sh         # -> dist/DaVoiceOnnxRuntime-1.31.0.zip (prints sha256)
```

`build_ort.sh` runs Microsoft's own `build_and_assemble_apple_pods.py` with these settings: CoreML, XNNPACK and
`--apple_deploy_target=15.1`, the same as the official iOS package, without Mac Catalyst.

Microsoft's GitHub repo is down, so the source comes from a public mirror. It is checked out at the exact v1.31.0
commit, `402979ac1bef89dcd55add41eaa7277c407599eb`, and git verifies every object against that hash.

## Publish (needs the DaVoice CocoaPods account)

1. Attach `dist/DaVoiceOnnxRuntime-<version>.zip` to this repo's GitHub release `v<version>`.
2. `scripts/set_source.sh <the release asset URL>`. It downloads the file, checks it is byte-identical to the local
   zip, and writes the URL and sha256 into the podspec.
3. `pod spec lint DaVoiceOnnxRuntime.podspec --allow-warnings`
4. `pod trunk push DaVoiceOnnxRuntime.podspec --allow-warnings`. Run `pod trunk register info@davoice.io 'DaVoice'`
   once first if this Mac has no trunk session.

## Verified (2026-11-22)

- **`pod spec lint` passes** with the zip served from a `file://` URL. That covers download, sha256, unpacking and
  the build in a temporary app.
- **The libraries build against it.** KeyWordDetection.xcframework and DavoiceTTS.xcframework build with no Swift
  changes. DavoiceTTS needed one include changed to `<onnxruntime/onnxruntime_cxx_api.h>`.
- **iPhone 17 Pro simulator, wake word:** the cordova-wake-word bridge inside a Capacitor app creates and destroys
  the `hey_lookdeep.dm` detector.
- **iPhone 17 Pro simulator, TTS:** DavoiceTTS loads `model_ex2_rich_kate.dm` (0.8 s), speaks a sentence and
  reports finished (3.0 s).
- **iPhone 17 Pro simulator, car agent:** the Cordova and the Capacitor car agent examples (wake word, speech and
  on-device agent plugins in one app, this pod once) build, load the voices and the agent, and run three car
  commands.
- **Not yet done:** a physical iPhone.
