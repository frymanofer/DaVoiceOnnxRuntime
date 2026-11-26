// swift-tools-version:5.9
// ONNX Runtime 1.31.0 for iOS as a Swift package: the same build and API as the DaVoiceOnnxRuntime pod.
//
//   .package(url: "https://github.com/frymanofer/DaVoiceOnnxRuntime", from: "1.31.0")
//   .product(name: "DaVoiceOnnxRuntime", package: "DaVoiceOnnxRuntime")
//
// Swift / Objective-C: `import onnxruntime_objc` (the same module as Microsoft's onnxruntime-objc pod).
// C / C++:             #include <onnxruntime/onnxruntime_cxx_api.h>
//
// Use either this package or the pod in one app, never both, and never together with Microsoft's
// onnxruntime-c / onnxruntime-objc pods or onnxruntime-swift-package-manager (same module and symbols).
import PackageDescription

let package = Package(
    name: "DaVoiceOnnxRuntime",
    platforms: [.iOS("15.1")],
    products: [
        .library(name: "DaVoiceOnnxRuntime", targets: ["onnxruntime_objc"]),
    ],
    targets: [
        // The ONNX Runtime library (static xcframework with the C/C++ API headers): the pod's release zip.
        .binaryTarget(
            name: "onnxruntime",
            url: "https://github.com/frymanofer/DaVoiceOnnxRuntime/releases/download/v1.31.0/DaVoiceOnnxRuntime-1.31.0.zip",
            checksum: "c34da04945ed6d43a4efc4c163c87e18d5ae7e26a54b10b22a72a55070185eac"
        ),
        // The Objective-C API: Microsoft's onnxruntime-objc sources, unchanged (SPM_BUILD is their own switch
        // for including the C/C++ headers as <onnxruntime/...>). No -fobjc-arc-exceptions as in the pod: SwiftPM
        // rejects unsafe flags in a versioned dependency, and these sources turn every C++ exception into an
        // NSError inside the same method, so no exception crosses ARC code.
        .target(
            name: "onnxruntime_objc",
            dependencies: ["onnxruntime"],
            path: "Sources/onnxruntime_objc",
            cxxSettings: [.define("SPM_BUILD")],
            linkerSettings: [
                // the same as the pod
                .linkedLibrary("c++"), .linkedLibrary("z"), .linkedLibrary("sqlite3"),
                .linkedFramework("CoreML"), .linkedFramework("CoreFoundation"), .linkedFramework("Foundation"),
                .linkedFramework("Network"), .linkedFramework("Security"), .linkedFramework("SystemConfiguration"),
                .linkedFramework("UIKit"),
            ]
        ),
    ],
    cxxLanguageStandard: .cxx17
)
