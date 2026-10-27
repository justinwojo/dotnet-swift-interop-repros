#!/bin/bash
# Builds native-build/InteropProbe.framework (iOS Simulator arm64) from Probe.swift
# and ProbeCaller.c, and emits the LLVM IR used to document the Swift ABI.
set -euo pipefail
cd "$(dirname "$0")"
: "${DEVELOPER_DIR:?Set DEVELOPER_DIR to the selected Xcode Contents/Developer directory}"
mkdir -p native-build/InteropProbe.framework artifacts
sdk="$(xcrun --sdk iphonesimulator --show-sdk-path)"
target=arm64-apple-ios16.0-simulator
xcrun --sdk iphonesimulator clang -target "$target" -isysroot "$sdk" -O2 -c ProbeCaller.c \
  -o native-build/ProbeCaller.o
xcrun --sdk iphonesimulator swiftc -module-name InteropProbe -emit-library -enable-library-evolution \
  -target "$target" -sdk "$sdk" -O \
  -Xlinker -install_name -Xlinker @rpath/InteropProbe.framework/InteropProbe \
  Probe.swift native-build/ProbeCaller.o -o native-build/InteropProbe.framework/InteropProbe
xcrun --sdk iphonesimulator swiftc -module-name InteropProbe -emit-ir -parse-as-library -enable-library-evolution \
  -target "$target" -sdk "$sdk" -O Probe.swift -o artifacts/Probe.ll
xcrun --sdk iphonesimulator clang -target "$target" -isysroot "$sdk" -O2 -S -emit-llvm ProbeCaller.c \
  -o artifacts/ProbeCaller.ll
cat > native-build/InteropProbe.framework/Info.plist <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>com.swiftinteroprepro.InteropProbe</string>
<key>CFBundleName</key><string>InteropProbe</string>
<key>CFBundleExecutable</key><string>InteropProbe</string>
<key>CFBundlePackageType</key><string>FMWK</string>
<key>CFBundleVersion</key><string>1</string>
<key>MinimumOSVersion</key><string>16.0</string>
</dict></plist>
PLIST
xcrun nm -gU native-build/InteropProbe.framework/InteropProbe > artifacts/native-symbols.txt
