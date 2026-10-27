#!/bin/bash
# Builds libSwiftErrorProbe.dylib for the host (macOS arm64) and emits its LLVM IR.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p artifacts
xcrun swiftc -module-name SwiftErrorProbe -emit-library -enable-library-evolution -O Probe.swift -o libSwiftErrorProbe.dylib
xcrun swiftc -module-name SwiftErrorProbe -emit-ir -parse-as-library -enable-library-evolution -O Probe.swift -o artifacts/Probe.ll
xcrun nm -gU libSwiftErrorProbe.dylib | grep plainThrows
