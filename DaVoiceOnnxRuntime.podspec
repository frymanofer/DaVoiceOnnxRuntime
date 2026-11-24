# ONNX Runtime for iOS in one pod, built by DaVoice from the official v1.31.0 source.
#
# Why: Microsoft's onnxruntime-c / onnxruntime-objc pods cannot be installed since November 2026
# (their download host, download.onnxruntime.ai, serves a certificate for *.azureedge.net), and
# there is no 1.31 pod. This pod provides the same Objective-C module (onnxruntime_objc) and the
# C/C++ API, so code written for onnxruntime-objc works unchanged.
#
# The zip is made by scripts/make_pod_zip.sh. Before `pod trunk push`, scripts/set_source.sh puts
# the public zip URL and its sha256 in the source line below (see README.md).
Pod::Spec.new do |s|
  s.name         = 'DaVoiceOnnxRuntime'
  s.version      = '1.31.0'
  s.summary      = 'ONNX Runtime 1.31.0 for iOS (Objective-C and C/C++ APIs) in one pod.'
  s.description  = <<-DESC
    ONNX Runtime 1.31.0 with the CPU, CoreML and XNNPACK execution providers for iOS 15.1 and newer,
    built from the official v1.31.0 source with the official Apple packaging script. It provides the
    same Objective-C module as Microsoft's onnxruntime-objc pod (onnxruntime_objc) plus the C/C++ API
    headers (#include <onnxruntime/onnxruntime_cxx_api.h>). Used by the DaVoice wake word, speech and
    voice libraries. Do not use it together with the onnxruntime-c / onnxruntime-objc pods in one app.
  DESC
  s.homepage     = 'https://davoice.io'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'DaVoice.io' => 'info@davoice.io' }
  s.source       = { :http => 'https://github.com/frymanofer/DaVoiceOnnxRuntime/releases/download/v1.31.0/DaVoiceOnnxRuntime-1.31.0.zip', :sha256 => 'c34da04945ed6d43a4efc4c163c87e18d5ae7e26a54b10b22a72a55070185eac' }

  s.ios.deployment_target = '15.1'
  s.module_name      = 'onnxruntime_objc'
  s.static_framework = true
  s.requires_arc     = true

  # The ONNX Runtime library (static) with its C/C++ headers.
  s.vendored_frameworks = 'onnxruntime.xcframework'
  s.weak_frameworks     = 'CoreML'
  s.frameworks          = 'CoreFoundation', 'Foundation', 'Network', 'Security', 'SystemConfiguration', 'UIKit'
  s.libraries           = 'c++', 'z', 'sqlite3'

  # The Objective-C API (Microsoft's onnxruntime-objc sources, unchanged).
  s.source_files        = 'objectivec/*.{h,mm}', 'objectivec/include/*.h'
  s.public_header_files = 'objectivec/include/*.h'
  s.preserve_paths      = 'Headers/*.h', 'LICENSE', 'ThirdPartyNotices.txt'
  s.compiler_flags      = '-std=c++17', '-fobjc-arc-exceptions'
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS'  => '"${PODS_TARGET_SRCROOT}/objectivec" "${PODS_TARGET_SRCROOT}/Headers"',
    'OTHER_CPLUSPLUSFLAGS' => '-fvisibility=hidden -fvisibility-inlines-hidden',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
  }
end
